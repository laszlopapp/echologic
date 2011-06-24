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
							return truncateBreadcrumbKey($(this));
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
						var origin_bids = getOriginKeys(new_bids);
	          var origin = origin_bids.length > 0 ? origin_bids[origin_bids.length -1] : '';
	          if (origin == null || origin == "undefined") {
	            origin = '';
	          }

						if (sids.join(",") == $.fragment().sids) {
			        /* sids won't change, we are inside a new form, and we press the breadcrumb to go back*/
							var path = $.queryString($(this).attr('href'), {"sids" : sids.join(","), "bids" : ''});
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

      function truncateBreadcrumbKey(breadcrumb) {
				var key = breadcrumb.attr('id') == 'sr' ?
                    (breadcrumb.attr('id') + breadcrumb.find('.search_link').text().replace(/,/, "\\;")) :
                    breadcrumb.attr('id');
				if (breadcrumb.attr('page_count')) {
					key += "|" + breadcrumb.attr('page_count');
				}
				return key;
			}

		/*
		 * Deletes Breadcrumbs that are not defined on the bids fragment (and after the last element clicked)
		 */
		 function cleanBreadcrumbs() {
          var jsp = breadcrumbs.data('jsp');
          var elements = jsp.getContentPane().find('.elements');
          var delete_from = breadcrumbs.data('element_clicked');

          if (delete_from && delete_from.length > 0) { /* if a special link was clicked */
            if($.inArray(delete_from.substring(0,2),['ds','sr']) != -1){delete_from = delete_from.substring(0,2);}

            // Get breadcrumbs ordered per id
            var breadcrumb_ids = elements.find('.breadcrumb').map(function(){return $(this).attr('id')});
            var remove_length;

            // There is an origin, so delete breadcrumbs to the right

            var index = $.inArray(delete_from, breadcrumb_ids);
            var to_remove = elements.find('.breadcrumb:eq(' + (index) + ')');
						var to_remove_elements = to_remove.nextAll();
						var remove_length = to_remove_elements.length;
            to_remove_elements.remove();
            


          } else { // delete all breadcrumbs that are not in the fragment bids

            var bids = $.fragment().bids;
            var remove_length = 0;
            bids = bids ? bids.split(',') : [];
            // No origin, that means first breadcrumb pressed, no predecessor, so delete everything
            elements.find('.breadcrumb').each(function() {
              if($.inArray(truncateBreadcrumbKey($(this)), bids) == -1) {
                remove_length += $(this).length;
                $(this).remove();
              }
            });
          }
          breadcrumbs.removeData('element_clicked');

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
        }

      function buildBreadcrumb(data, index, breadcrumbs_length) {
        var b_key = data['key'].substring(0,2);
				var breadcrumb = $('<a/>').addClass('breadcrumb').attr('id',data['key']).attr('href',data['url']).addClass(b_key);
        if (data['page_count']) {
          breadcrumb.attr('page_count', data['page_count']);
        }
        if (index != 0 || breadcrumbs_length != 0) {
          breadcrumb.append($("<span/>").addClass('big_delimiter'));
        }
        breadcrumb.append($('<span/>').addClass('label').text(data['label']));
        breadcrumb.append($('<span/>').addClass('over').text(data['over']));
        breadcrumb.append($('<span/>').addClass(data['css']).text(data['title']));
        breadcrumb.hide();
        initBreadcrumb(breadcrumb);
				return breadcrumb;
			}

			// Public API
      $.extend(this,
      {
        reinitialise: function()
        {
          initialise();
        },
				getBreadcrumb: function(key) {
					return breadcrumbs.data('jsp').getContentPane().find('#'+key);
				},
        deleteBreadcrumbs: function()
				{
					cleanBreadcrumbs();
					return this;
				},
				deleteBreadcrumb: function(key) // IMPORTANT: ONLY REMOVES VISUALLY
				{
					if (key && key.length > 0) {
						var origin = $.fragment().origin;
						if ($.inArray(origin.substring(0,2),['ds','sr']) != -1){origin = origin.substring(0,2);}
						var top_breadcrumb = origin.length > 0 ? breadcrumbs.find('#' + origin) : breadcrumbs.find('.breadcrumb:first');
						var breadcrumb = top_breadcrumb.nextAll('#' + key).remove();
					}
					return this;
				},
				addBreadcrumbs : function(breadcrumbsData) {

					var jsp = breadcrumbs.data('jsp');
          var elements = jsp.getContentPane().find(".elements");

					if (breadcrumbsData) {
						if(breadcrumbs.is(":hidden")) {
              toggleContainer();
            }

						var breadcrumbs_length = elements.find(".breadcrumb").length;
			  	  // Assemble new breadcrumb entries
						$.each(breadcrumbsData, function(index, breadcrumbData) { //[id, classes, url, title, label, over]
						  if (breadcrumbs.find('#' + breadcrumbData['key']).length == 0) {
						  	var breadcrumb = buildBreadcrumb(breadcrumbData, index, breadcrumbs_length);
						  	elements.append(breadcrumb);
						  }
						});
					}
					var width = updateContainerWidth();
          jsp.reinitialise();
					jsp.scrollToX(width);
          elements.find('.breadcrumb:hidden').animate(settings['breadcrumb_animation_params'],
                                                      settings['animation_speed']);
				},


				breadcrumbsToLoad : function (bids) {
		      if (bids == null) { return []; }
		      // Current bids in the list
		      var bid_list = bids.split(",");



					var delete_from = breadcrumbs.data('element_clicked');
					if (delete_from) {
		        var index = $.inArray(delete_from, bid_list);
						return index == -1 ? bid_list : (index >= bid_list.length ? [] : bid_list.splice(index+1, bid_list.length));
				  }
				  else {
						// Current breadcrumb entries
	          var visible_bids = breadcrumbs.find(".breadcrumb").map(function() {
	            return truncateBreadcrumbKey($(this));
	          }).get();

				  	// Get bids that are not visible (DRY)
						return $.grep(bid_list, function(a, index){
							return $.inArray(a, visible_bids) == -1;
						});
					}
		    },

				getBreadcrumbStack : function (newBreadcrumb) {
		      var currentBreadcrumbs = breadcrumbs.find(".breadcrumb").map(function() {
						return truncateBreadcrumbKey($(this));
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
