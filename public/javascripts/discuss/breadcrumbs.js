(function($) {

  $.fn.breadcrumbs = function(currentSettings){

    $.fn.breadcrumbs.defaults = {
      'container_animation_params' : {
        'width' : 'toggle',
        'opacity': 'toggle'
      },
      'breadcrumb_animation_params' : {
        'width' : 'toggle',
        'opacity': 'toggle'
      },
      'animation_speed': 700
    };

		// Merging settings with defaults
    var settings = $.extend({}, $.fn.breadcrumbs.defaults, currentSettings);

    // Creating and binding the breadcrumb API
    var api = this.data('breadcrumbApi');
    if (api) {
      api.reinitialise(settings);
    } else {
    api = new Breadcrumbs(this);
      this.data('breadcrumbApi', api);
    }
    return this;


    /***************************/
    /* The breadcrumbs handler */
    /***************************/

    function Breadcrumbs(breadcrumbs) {
      initialise();

			function initialise(){
				breadcrumbs.find('a');
				breadcrumbs.find('a').each(function(){
				  initBreadcrumb($(this));
				});

				var jsp = breadcrumbs.data('jsp');

				var width = updateContainerWidth();
				jsp.reinitialise();
        jsp.scrollToX(width);

				var elements = jsp.getContentPane().find('.elements');
				if (elements.children().length == 0) {
          toggleContainer();
        }
	    }


      /*
       * Initializes the links in the different sort of breadcrumbs.
       */
			function initBreadcrumb(breadcrumb) {

        if (breadcrumb.hasClass('.search_link')) {return;}

        // Loads ids of the statements appearing in the stack
		    var path_id = breadcrumb.attr('id');
				path_id = path_id.substring(2, path_id.length);
		    var path = breadcrumb.attr('href').replace(/\/\d+.*/, '/' + path_id + '/' + 'ancestors');
				var sids;
		    $.getJSON(path, function(data) {
		      sids = data;
		    });

		    breadcrumb.bind("click", function() {
		      // Getting bids from fragment
		      var bids_stack = $.fragment().bids;
		      bids_stack = (bids_stack == null) ? [] : bids_stack.split(',');

		      // Getting links that must be removed from the breadcrumbs
		      var links_to_delete = $(this).parent().nextAll().map(function() {
		        return $(this).find('.statement').attr('id');
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

		      $.setFragment({
            "bids" : new_bids.join(","),
            "sids": sids.join(","),
            "new_level" : true,
            "origin" : origin
          });
		      return false;
		    });
		  }

			function updateContainerWidth() {
				var jsp = breadcrumbs.data('jsp');
        var elements = jsp.getContentPane().find(".elements");

				// Calculate width
        var width = 0;
        elements.children().each(function(){
          width += $(this).outerWidth();
        });
        elements.width(width);
				return width;
			}


      /*
       * Shows / hides the breadcrumbs container with all its breadcrumbs
       * (actually, there are no breadcrumbs when it gets hidden).
       */
      function toggleContainer() {
        breadcrumbs.animate(settings['container_animation_params'],
                            settings['animation_speed']);
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
						$.each(breadcrumbsData, function(index, breadcrumbData) {
							var breadcrumb = $('<div/>').addClass('breadcrumb');
							if (index != 0 || elements.find(".breadcrumb").length != 0) {
								breadcrumb.append($("<span/>").addClass('delimiter').text(">"));
							}
              breadcrumb.append($('<span/>').addClass('label').text(breadcrumbData[4]));
							breadcrumb.append($('<span/>').addClass('over').text(breadcrumbData[5]));
							breadcrumb.append($('<a/>').
                         attr('id', breadcrumbData[0]).
                         addClass(breadcrumbData[1]).
                         attr('href', breadcrumbData[2]).
                         text(breadcrumbData[3]));
							breadcrumb.hide();
							initBreadcrumb(breadcrumb.find('a'));
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
            // There is an origin, so delete breadcrumbs to the right
				  	elements.find('a#' + originId).parent().nextAll().remove();
				  } else {
            // No origin, that means first breadcrumb pressed, no predecessor, so delete everything
						elements.find('a').each(function() {
						  $(this).parent().remove();
						});
					}

					updateContainerWidth();
					jsp.scrollToX(0);
					jsp.reinitialise();
					if (jsp.getContentPane().find('a').length == 0) {
            toggleContainer();
          }
					return this;
				},

				breadcrumbsToLoad : function (bids) {
		      if (bids == null) { return []; }
		      // Current bids in the list
		      var bid_list = bids.split(",");

		      // Current breadcrumb entries
		      var visible_bids = breadcrumbs.find("a").map(function() {
						return this.id;
		      }).get();

		      // Get bids that are not visible (DRY)
          return $.grep(bid_list, function(a, index) {
		        return $.inArray(a, visible_bids) == -1;
          });
		    },

				getBreadcrumbStack : function (newBreadcrumb) {
		      var currentBreadcrumbs = breadcrumbs.find(".breadcrumb a").map(function() {
						return this.id;
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
