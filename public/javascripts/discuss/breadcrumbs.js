(function($) {

  $.fn.breadcrumbs = function(currentSettings){

    $.fn.breadcrumbs.defaults = {
      'container_animation_params' : {
        'height' : 'toggle',
        'opacity': 'toggle'
      },
      'container_animation_speed': 400,
      'breadcrumb_animation_params' : {
        'width' : 'toggle',
        'opacity': 'toggle'
      },
      'animation_speed': 600
    };

		// Merging settings with defaults
    var settings = $.extend({}, $.fn.breadcrumbs.defaults, currentSettings);

    return this.each(function() {
	    // Creating and binding the breadcrumb API
	    var elem = $(this), breadcrumbApi = elem.data('breadcrumbApi');
	    if (breadcrumbApi) {
	      breadcrumbApi.reinitialise();
	    } else {
	    breadcrumbApi = new Breadcrumbs(elem);
	      elem.data('breadcrumbApi', breadcrumbApi);
	    }
		});


    /***************************/
    /* The breadcrumbs handler */
    /***************************/

    function Breadcrumbs(breadcrumbs) {
      initialise();

			function initialise(){
				breadcrumbs.find('.breadcrumb').each(function() {
				  initBreadcrumb($(this));
				});

        breadcrumbs.jScrollPane({animateScroll: true});
				var jsp = breadcrumbs.data('jsp');

				var width = updateContainerWidth();
				jsp.reinitialise();
        jsp.scrollToX(width);

				var elements = jsp.getContentPane().find('.elements');
				if (elements.children().length == 0) {
					if (breadcrumbs.is(':visible')) {
				  	toggleContainer();
				  }
        }
	    }


      /*
       * Initializes the links in the different sort of breadcrumbs.
       */
			function initBreadcrumb(breadcrumb) {
        if (!breadcrumb.children(':last').hasClass('statement')) {return;}

        // Loads ids of the statements appearing in the stack
		    var path_id = breadcrumb.attr('id');
				path_id = path_id.substring(2, path_id.length);
		    var path = breadcrumb.attr('href').replace(/\/\d+.*/, '/' + path_id + '/' + 'ancestors');
				var sids;
		    $.getJSON(path, function(data) {
		      sids = data;
					
					breadcrumb.bind("click", function() {
	          // Getting bids from fragment
	          var bids_stack = $(this).prevAll().map(function() {
	            return  this.id == 'sr' ? (this.id + $(this).find('.search_link').text().replace(/,/, "\\;")) : this.id;
	          }).get().reverse();
	          
	          
	          // Getting links that must be removed from the breadcrumbs
	          var links_to_delete = $(this).nextAll().map(function() {
	            return $(this).attr('id');
	          }).get();
	          links_to_delete.unshift($(this).attr('id'));
	
	          var new_bids = $.grep(bids_stack, function(a, index) {
	            return $.inArray(a, links_to_delete) == -1;
	          });
	
	          // Getting previous breadcrumb entry, in order to load the proper siblings to session
	          var origin = new_bids[new_bids.length -1];
	          if (origin == null || origin == "undefined") {
	            origin = '';
	          }
						if (sids.join(",") == $.fragment().sids) {
			        /* sids won't change, we are inside a new form, and we press the breadcrumb to go back*/
							var path = $.queryString($(this).attr('href'), {"sids" : sids.join(",")});
							$.getScript(path);
						}
						else {
							$.setFragment({
								"bids": new_bids.join(","),
								"sids": sids.join(","),
								"new_level": true,
								"origin": origin
							});
						}
	          return false;
	        });
		    });

		    
		  }

			function updateContainerWidth() {
				var jsp = breadcrumbs.data('jsp');
        var container = jsp.getContentPane().find(".elements");

				// Calculate width
        var width = 0;
        container.children().each(function(){
          width += $(this).outerWidth();
        });
        container.width(width);
				return width;
			}


      /*
       * Shows / hides the breadcrumbs container with all its breadcrumbs
       * (actually, there are no breadcrumbs when it gets hidden).
       */
      function toggleContainer() {
        breadcrumbs.animate(settings['container_animation_params'],
                            settings['container_animation_speed']);
      }


			// Public API
      $.extend(this,
      {
        reinitialise: function()
        {
          initialise();
        },

				addBreadcrumbs : function(breadcrumbsData) {

					var jsp = breadcrumbs.data('jsp');
          var elements = jsp.getContentPane().find(".elements");

					if (breadcrumbsData) {
						if(breadcrumbs.is(":hidden")) {
              toggleContainer();
            }
			  	  // Assemble new breadcrumb entries
						$.each(breadcrumbsData, function(index, breadcrumbData) { //[id, classes, url, title, label, over]
							var breadcrumb = $('<a/>').addClass('breadcrumb').attr('id',breadcrumbData[0]).attr('href',breadcrumbData[2]);
							if (index != 0 || elements.find(".breadcrumb").length != 0) {
								breadcrumb.append($("<span/>").addClass('delimiter').text(">"));
							}
              breadcrumb.append($('<span/>').addClass('label').text(breadcrumbData[4]));
							breadcrumb.append($('<span/>').addClass('over').text(breadcrumbData[5]));
							breadcrumb.append($('<span/>').addClass(breadcrumbData[1]).text(breadcrumbData[3]));
							breadcrumb.hide();
							initBreadcrumb(breadcrumb);
							elements.append(breadcrumb);
						});
					}
					var width = updateContainerWidth();
          jsp.reinitialise();
					jsp.scrollToX(width);
          elements.find('.breadcrumb:hidden').animate(settings['breadcrumb_animation_params'],
                                                      settings['animation_speed']);
				},

				deleteAfter : function (originId) {
					var jsp = breadcrumbs.data('jsp');
					var elements = jsp.getContentPane().find('.elements');
					if (originId.length > 0) {
						if(originId.substring(0,2) == 'sr'){originId = 'sr';}
            // There is an origin, so delete breadcrumbs to the right
				  	var to_remove = elements.find('a#' + originId).nextAll().remove();
            var remove_length = to_remove.length;
            to_remove.remove();
				  } else {
						// No origin, that means first breadcrumb pressed, no predecessor, so delete everything
						elements.find('a').each(function() {
						  $(this).remove();
						});
					}

          if (remove_length > 0) {
            jsp.scrollToX(0);
            updateContainerWidth();
            jsp.reinitialise();
          }
			  	if (jsp.getContentPane().find('a').length == 0) {
						if (breadcrumbs.is(':visible')) {
							toggleContainer();
						}
			  	}
			  	return this;
				},

				breadcrumbsToLoad : function (bids) {
		      if (bids == null) { return []; }
		      // Current bids in the list
		      var bid_list = bids.split(",");

          // Current breadcrumb entries
		      var visible_bids = breadcrumbs.find(".breadcrumb").map(function() {
						return  this.id == 'sr' ? (this.id + $(this).find('.search_link').text().replace(/,/, "\\;")) : this.id;
		      }).get();
					
					// Get bids that are not visible (DRY)
          return $.grep(bid_list, function(a, index) {
					  return $.inArray(a, visible_bids) == -1;
          });
		    },

				getBreadcrumbStack : function (newBreadcrumb) {
		      var currentBreadcrumbs = breadcrumbs.find(".breadcrumb").map(function() {
						return  this.id == 'sr' ? (this.id + $(this).find('.search_link').text().replace(/,/, "\\;")) : this.id;
					}).get();
					if (newBreadcrumb) {
            currentBreadcrumbs.push(newBreadcrumb);
          }

		      return currentBreadcrumbs;
		    }
			});
    }

  };

})(jQuery);
