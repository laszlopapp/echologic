(function($, window, undefined){

  $.fn.breadcrumb = function(settings){

    function Breadcrumb(breadcrumbs_container){
      var breadcrumbs = breadcrumbs_container;
      initialise();

			function initialise(){
				breadcrumbs.find('a').each(function(){
				  initBreadcrumb($(this));
				});
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
		    var path_id = breadcrumb.attr('href').match(/\/\d+/);
		    var path = breadcrumb.attr('href').replace(/\/\d+.*/, path_id + '/' + 'ancestors');
		    $.getJSON(path, function(data) {
		      var sids = data;
		      breadcrumb.data('sids', sids);
		    });

		    breadcrumb.bind("click", function(){
		      /* get bids from fragment */
		      var bids_stack = $.fragment().bids;
		      bids_stack = (bids_stack == null) ? [] : bids_stack.split(',');

		      /* get keys for comparison */
		      var bid_keys = $.map(bids_stack, function(a) {
		        var key = a.substring(0, 2);
		        return key!='fq' ? key : a.substring(2, a.length);
		      });
		      /* get links that must vanish from the breadcrumbs */
		      var links_to_delete = $(this).parent().nextAll().map(function(){
		        return $(this).find('.statement').attr('id');
		      }).get();
		      links_to_delete.unshift($(this).attr('id'));


		      /* set new bids to save in fragment */
		      id_links_to_delete = $.map(links_to_delete, function(a){
		        return getStatementId(a);
		      });

		      new_bids = $.grep(bids_stack, function(a, index){
		        return $.inArray(bid_keys[index], id_links_to_delete) == -1;
		      });

		      /* save the breadcrumbs to be deleted after the request */
		      $("#breadcrumbs").data('to_delete', links_to_delete);
		      /* set fragment */
		      var sids = $(this).data('sids');

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

			// Public API
      $.extend(this,
      {
        reinitialise: function(s)
        {
          s = $.extend({}, s, settings);
          initialise(s);
        },
				// API Functions
				add : function (attrs) { /* Array: [id, classes, url, title, label] */
				  var api = breadcrumbs.data('jsp');
				  var elements = api.getContentPane().find(".elements");//this.find('.elements');

				  if (elements.find('a#' + attrs[0]).length > 0) {
				   return;
				  }

				  var breadcrumb = $('<div/>').addClass('breadcrumb');
					breadcrumb.append($('<span/>').addClass('label').text(attrs[4]));
					breadcrumb.append($('<span/>').addClass('over').text(attrs[5]).hide());
					if (api.getContentPane().find(".elements .breadcrumb").length != 0) {
				    var del = $("<span class='delimitator'>></span>");
				    breadcrumb.append(del);
				  }
				  breadcrumb.append($('<a></a>').attr('id', attrs[0]).addClass(attrs[1]).attr('href',attrs[2]).text(attrs[3]));
				  elements.append(breadcrumb);
					initBreadcrumb(breadcrumb.find('a'));

					return this;
				},

				update : function () {
					var links_to_delete = breadcrumbs.data('to_delete');
		      if (links_to_delete != null) {
		        $.each(links_to_delete, function(index, value){
		          var link = breadcrumbs.find('#' + value);
		          link.parent().remove();
		        });
		        breadcrumbs.removeData('to_delete');
		      }
					return this;
		    },
				resize : function () {
		      var elements = breadcrumbs.find('.elements');
		      var api = breadcrumbs.data('jsp');

		      var width = 0;
		      elements.children().each(function(){
		        width += $(this).outerWidth();
		      });

		      elements.width(width);
		      api.reinitialise();
		      api.scrollByX(width);

					return this;
		    },
				breadcrumbsToLoad : function (bids) {
		      if (bids == null) { return []; }
		      /* current bids in stack */
		      var bids_stack = bids.split(",");


		      /* get keys for comparison */
		      var bid_keys = $.map(bids_stack, function(a) {
		        var key = a.substring(0, 2);
		        return key!='fq' ? key : a.substring(2, a.length);
		      });

		      /* current breadcrumb entries */
		      var visible_bids = breadcrumbs.find("a").map(function(){
		        if ($(this).hasClass('statement')) {
		          return getStatementId(this.id);
		        } else {
		          return this.id;
		        }
		      }).get();

		      /* delete entries that do not belong to the breadcrumbs' stack */
		      var to_remove = [];
		      $.map(visible_bids, function(a, index) {
		       if($.inArray(a, bid_keys) == -1) {
		         to_remove.push($("#breadcrumbs a").eq(index).attr('id'));
		       }
		      });

					var to_delete = $("#breadcrumbs").data('to_delete');
					if (to_delete) {$.merge(to_remove, to_delete);}
					$("#breadcrumbs").data('to_delete', to_remove);

		      /*$.each(to_remove, function(){
		        this.remove();
		      });*/

		      /* get bids that are not visible (don't repeat yourself) */
		      var bids_to_load = $.grep(bids_stack, function(a, index){
		        return $.inArray(bid_keys[index], visible_bids) == -1 ;});

		      return bids_to_load;
		    },
				getBreadcrumbStack : function (element){
		      var current_breadcrumbs = breadcrumbs.find(".breadcrumb a").map(function(){
						return this.id.split('_').join('');
					}).get();
					if (element) {
		        var statement_id = getStatementId(element.parents('.statement').attr('id'));
		        current_breadcrumbs.push('fq' + statement_id);
		      }
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
