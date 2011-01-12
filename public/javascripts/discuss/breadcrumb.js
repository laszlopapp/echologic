(function($, window, undefined){

  $.fn.breadcrumb = function(settings){
    
    function Breadcrumb(elem, s){
		
      var jsp = this;
      
      initialise(s);
      
			function initialise(s){
				elem.find('a.breadcrumb').each(function(){
				  initBreadcrumbHistoryEvents($(this));	
				});
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
		        var aux = a.split('=>');
		        return aux[0]!='fq' ? aux[0] : aux[1];
		      });
		      /* get links that must vanish from the breadcrumbs */
		      var links_to_delete = $(this).parent().nextAll().map(function(){
		        return $(this).find('.statement').attr('id');
		      }).get();
		      links_to_delete.unshift($(this).attr('id'));
		
		      
		      /* set new bids to save in fragment */
		      id_links_to_delete = $.map(links_to_delete, function(a){
		        return a.replace(/[^0-9]+/, '');
		      });
		      new_bids = $.grep(bids_stack, function(a, index){
		        return $.inArray(bid_keys[index], id_links_to_delete) == -1;
		      });
		      
		      /* save the breadcrumbs to be deleted after the request */
		      $("#breadcrumbs").data('to_delete', links_to_delete);
		      /* set fragment */
		      var sids = $(this).data('sids');
		      
		      /* get previous breadcrumb entry, in order to load the proper siblings to session */
		      var prev = new_bids[new_bids.length -1];
		      
		      $.setFragment({"bids" : new_bids.join(","), "sids": sids.join(","), "new_level" : '', "prev" : prev});
		      return false;
		    });
		  }
			
			
			// Public API
      $.extend(jsp, 
      {
        reinitialise: function(s)
        {
          s = $.extend({}, s, settings);
          initialise(s);
        },
				// API Functions
				add : function (attrs) { /* Array: [id, classes, url, title] */
				  var api = elem.data('jsp');
				  var elements = api.getContentPane().find(".elements");//this.find('.elements');
				  
				  if (elements.find('a#' + attrs[0]).length > 0) {
				   return;
				  }
				  
				  var breadcrumb = $('<div/>').addClass('breadcrumb');
				  if (elem.length != 0) {
				    var del = $("<span class='delimitator'>></span>");
				    breadcrumb.append(del);
				  }
				  breadcrumb.append($('<a></a>').attr('id', attrs[0]).addClass(attrs[1]).attr('href',attrs[2]).text(attrs[3]));
				  elements.append(breadcrumb);
					initBreadcrumbHistoryEvents(breadcrumb.find('a'));
					
					return elem;
				},
				
				update : function () {
					var breadcrumbs = elem;
					var links_to_delete = breadcrumbs.data('to_delete');
		      if (links_to_delete != null) {
		        $.each(links_to_delete, function(index, value){
		          var link = breadcrumbs.find('#' + value);
		          link.parent().remove();
		        });
		        breadcrumbs.removeData('to_delete');
		      }
					return elem;
		    },
				resize : function () {
		      var elements = elem.find('.elements');
		      var api = elem.data('jsp');
		
		      var width = 0;
		      elements.children().each(function(){
		        width += $(this).outerWidth();
		      });
		
		      elements.width(width);
		      api.reinitialise();
		      api.scrollByX(width);
					
					return elem;
		    },
				breadcrumbsToLoad : function (bids) {
		      if (bids == null) { return []; }
		      /* current bids in stack */
		      var bids_stack = bids.split(",");
		      
		      
		      /* get keys for comparison */
		      var bid_keys = $.map(bids_stack, function(a) {
		        var aux = a.split('=>');
		        return aux[0]!='fq' ? aux[0] : aux[1];
		      });
		      
		      /* current breadcrumb entries */
		      var visible_bids = elem.find("a").map(function(){
		        if ($(this).hasClass('statement')) {
		          return this.id.replace(/[^0-9]+/, '');
		        } else {
		          return this.id;
		        }
		      }).get();
		     
		       /* delete entries that do not belong to the breadcrumbs' stack */
		      var to_remove = [];
		      $.map(visible_bids, function(a, index) {
		       if($.inArray(a, bid_keys) == -1) {
		         to_remove.push($("#breadcrumbs a").eq(index).parent());
		       }
		      });
		      
		      
		      
		      $.each(to_remove, function(){
		        this.remove();
		      });
		      
		      /* get bids that are not visible (don't repeat yourself) */
		      var bids_to_load = $.grep(bids_stack, function(a, index){
		        return $.inArray(bid_keys[index], visible_bids) == -1 ;});
		      
		      return bids_to_load;
		    },
				getBreadcrumbStack : function (element){
		      var breadcrumbs = elem.find(".breadcrumb a.search_link").map(function(){
		        if (this.id == 'sr') {
		          return 'sr=>'+ $(this).getUrlParam('search_terms');
		        } else
		        {
		          return this.id;
		        }
		      }).get();
		      var node_breadcrumbs = elem.find(".breadcrumb a.statement").map(function(){
		        return 'fq=>'+ this.id.replace(/[^0-9]+/, '');
		      }).get();
		      $.merge(breadcrumbs, node_breadcrumbs);
		      if (element) {
		        var statement_id = element.parents('.statement').attr('id').replace(/[^0-9]+/, '');
		        breadcrumbs.push('fq=>' + statement_id);
		      }
		      return breadcrumbs;
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
    
      var elem = $(this), api = elem.data('api');
      if (api) {
        api.reinitialise(settings);
      } else {
      api = new Breadcrumb(elem, settings);
        elem.data('api', api);
      }
      ret = ret ? ret.add(elem) : elem;
    })
    return ret;
	
  };

})(jQuery,this);
