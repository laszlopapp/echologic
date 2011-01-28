(function($) {

  $.fn.breadcrumbs = function(currentSettings){

    $.fn.breadcrumb.defaults = {
      'animation_speed': 500
    };

		// Merging settings with defaults
    var settings = $.extend({}, $.fn.breadcrumb.defaults, currentSettings);

    // Creating and binding the breadcrumb API
    var api = this.data('breadcrumbApi');
    if (api) {
      api.reinitialise(settings);
    } else {
    api = new Breadcrumb();
      this.data('breadcrumbApi', api);
    }
    return this;


    /***************************/
    /* The breadcrumbs handler */
    /***************************/

    function Breadcrumb(breadcrumbs) {
      initialise();

			function initialise(){
				breadcrumbs.find('a');
				breadcrumbs.find('a').each(function(){
				  initBreadcrumb($(this));
				});

				var jsp = breadcrumbs.data('jsp');

				var width = updateContainerWidth();
				jsp.reinitialise();
        jsp.scrollByX(width);

				var elements = jsp.getContentPane().find('.elements');
				if (elements.children().length == 0) {breadcrumbs.fadeOut(settings['animation_speed']);}
	    }

		  function initBreadcrumb(breadcrumb) {
				if (!breadcrumb.hasClass('.search_link')) {
					initBreadcrumbLink(breadcrumb);
				}
			}


      /*
       * Initializes the links in the different sort of breadcrumbs.
       */
			function initBreadcrumbLink(breadcrumb) {

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

		      var new_bids = $.grep(bids_stack, function(a) {
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

			// Public API
      $.extend(this,
      {
        reinitialise: function()
        {
          initialise();
        },

				addBreadcrumbs : function(attrs_array) {

					var jsp = breadcrumbs.data('jsp');
          var elements = jsp.getContentPane().find(".elements");

					if (attrs_array) {
						if(breadcrumbs.is(":hidden")) {breadcrumbs.fadeIn(settings['animation_speed']);}
			  	  // load new breadcrumb entries
						$.each(attrs_array, function(index, attrs){
							var breadcrumb = $('<div/>').addClass('breadcrumb');
							breadcrumb.append($('<span/>').addClass('label').text(attrs[4]));
							breadcrumb.append($('<span/>').addClass('over').text(attrs[5]).hide());
							if (!index == 0 || elements.find(".breadcrumb").length != 0) {
								var del = $("<span/>").addClass('delimiter');
								breadcrumb.append(del);
							}
							breadcrumb.append($('<a/>').attr('id', attrs[0]).addClass(attrs[1]).attr('href', attrs[2]).text(attrs[3]));
							breadcrumb.hide();
							initBreadcrumb(breadcrumb.find('a'));
							elements.append(breadcrumb);
						});
					}
					var width = updateContainerWidth();

					jsp.reinitialise();
					jsp.scrollByX(width);

					elements.find('.breadcrumb:hidden').fadeIn(settings['animation_speed']);
				},

				deleteAfter : function (originId) {
					var jsp = breadcrumbs.data('jsp');
					var elements = jsp.getContentPane().find('.elements');
					if (originId.length > 0) {
            // there is an origin, so delete breadcrumbs to the right
				  	elements.find('a#' + originId).parent().nextAll().remove();
				  } else {
            // no origin, that means first breadcrumb pressed, no predecessor, so delete everything
						elements.find('a').each(function() {
						  $(this).parent().remove();
						});
					}

					updateContainerWidth();
					jsp.scrollToX(0);
					jsp.reinitialise();
					if (jsp.getContentPane().find('a').length == 0) {breadcrumbs.fadeOut(settings['animation_speed']);}
					return this;
				},

				breadcrumbsToLoad : function (bids) {
		      if (bids == null) { return []; }
		      // Current bids in stack
		      var bids_stack = bids.split(",");

		      // Current breadcrumb entries
		      var visible_bids = breadcrumbs.find("a").map(function(){
						return this.id;
		      }).get();

		      // Get bids that are not visible (don't repeat yourself)
          return $.grep(bids_stack, function(a) {
		        return $.inArray(a, visible_bids) == -1;
          });
		    },

				getBreadcrumbStack : function (new_breadcrumb){
		      var current_breadcrumbs = breadcrumbs.find(".breadcrumb a").map(function(){
						return this.id;
					}).get();
					if (new_breadcrumb) {current_breadcrumbs.push(new_breadcrumb);}

		      return current_breadcrumbs;
		    }
			});
    }

  };

})(jQuery);
