(function($, window, undefined){

  $.fn.breadcrumb = function(settings){

    function Breadcrumb(breadcrumbs_container){
      var breadcrumbs = breadcrumbs_container;
      initialise();

			function initialise(){
				breadcrumbs.find('a').each(function(){
				  initBreadcrumb($(this));
				});
				var elements = breadcrumbs.data('jsp').getContentPane();
				if (elements.children().length == 0) {breadcrumbs.fadeOut(settings['animation_speed']);}
	    }
        
		  function initBreadcrumb(breadcrumb) {
				if (!breadcrumb.hasClass('.search_link')) {
					initBreadcrumbHistoryEvents(breadcrumb);
				}
        initLabelOnMouseOver(breadcrumb);
			}
			
			
			
			
			// Auxiliary functions
			function initBreadcrumbHistoryEvents(breadcrumb) {
		    /*loads statement stack of ids into the button itself */
		    var path_id = breadcrumb.attr('id');
				path_id = path_id.substring(2, path_id.length);
		    var path = breadcrumb.attr('href').replace(/\/\d+.*/, '/' + path_id + '/' + 'ancestors');
				var sids;
				
		    $.getJSON(path, function(data) {
		      sids = data;
		    });

		    breadcrumb.bind("click", function(){
		      /* get bids from fragment */
		      var bids_stack = $.fragment().bids;
		      bids_stack = (bids_stack == null) ? [] : bids_stack.split(',');
		      
		      /* get links that must vanish from the breadcrumbs */
		      var links_to_delete = $(this).parent().nextAll().map(function(){
		        return $(this).find('.statement').attr('id');
		      }).get();
		      links_to_delete.unshift($(this).attr('id'));
		      
		      new_bids = $.grep(bids_stack, function(a, index){
		        return $.inArray(a, links_to_delete) == -1;
		      });
		      
		      /* get previous breadcrumb entry, in order to load the proper siblings to session */
		      var origin = new_bids[new_bids.length -1];
					if (origin == null || origin == "undefined") {
				  	origin = '';
				  }

		      $.setFragment({"bids" : new_bids.join(","), "sids": sids.join(","), "new_level" : true, "origin" : origin});
		      return false;
		    });
		  }

      function initLabelOnMouseOver(breadcrumb) {
				var label = breadcrumb.parent().find('.label');
				var over = breadcrumb.parent().find('.over');
				breadcrumb.bind('mouseover', function(){
					label.hide();
					over.show();
				});
				breadcrumb.bind('mouseleave', function(){
          label.show();
          over.hide();
        });
			}
			
			function updateContainerWidth(elements) {
				var jsp = breadcrumbs.data('jsp');
        var elements = jsp.getContentPane().find(".elements");
				
				/* calculate width */
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
        reinitialise: function(s)
        {
          s = $.extend({}, s, settings);
          initialise(s);
        },
				// API Functions
				addBreadcrumbs : function(attrs_array) {
					
					var jsp = breadcrumbs.data('jsp');
          var elements = jsp.getContentPane().find(".elements");
					
					if (attrs_array) {
						if(breadcrumbs.is(":hidden")) {breadcrumbs.fadeIn(settings['animation_speed']);}
			  	  /* load new breadcrumb entries */
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
				deleteAfter : function (origin_id) {
					var jsp = breadcrumbs.data('jsp');
					var elements = jsp.getContentPane().find('.elements');
					if (origin_id.length > 0) { // there is an origin, so delete breadcrumbs to the right 
				  	var origin = elements.find('a#' + origin_id).parent();
						origin.nextAll().remove();
				  } else { // no origin, that means first breadcrumb pressed, no predecessor, so delete everything
						var origin = elements.find('a').each(function(){
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
		      /* current bids in stack */
		      var bids_stack = bids.split(",");
		      
		      /* current breadcrumb entries */
		      var visible_bids = breadcrumbs.find("a").map(function(){
						return this.id;
		      }).get();

		      /* get bids that are not visible (don't repeat yourself) */
		      var bids_to_load = $.grep(bids_stack, function(a, index){
		        return $.inArray(a, visible_bids) == -1 ;});

		      return bids_to_load;
		    },
				
				getBreadcrumbStack : function (new_breadcrumb){
		      var current_breadcrumbs = breadcrumbs.find(".breadcrumb a").map(function(){
						return this.id;
					}).get();
					if (new_breadcrumb) {current_breadcrumbs.push(new_breadcrumb);}
					
		      return current_breadcrumbs;
		    }
			});
    };

		$.fn.breadcrumb.defaults = {
      'animation_speed': 500
    };

		// Pluginifying code...
    settings = $.extend({}, $.fn.breadcrumb.defaults, settings);

	  var ret;
    this.each(function(){

      var elem = $(this), api = elem.data('breadcrumbApi');
      if (api) {
        api.reinitialise(settings);
      } else {
      api = new Breadcrumb(elem, settings);
        elem.data('breadcrumbApi', api);
      }
      ret = ret ? ret.add(elem) : elem;
    })
    return ret;

  };

})(jQuery,this);
