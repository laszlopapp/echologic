(function( $ ){

  var settings = {
      'animation_speed': 500
    };


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
	    $.setFragment({"bids" : new_bids.join(","), "sids": sids.join(","), "new_level" : ''});
	    return false;
	  });
	}

  var methods = {
     init : function( options ) {
		 	this.each(function(){
				initBreadcrumbHistoryEvents($(this));
      });
		 },
		 
		 add : function (attrs) { /* Array: [id, classes, url, title] */
		  var api = this.data('jsp');
		  var elements = api.getContentPane().find(".elements");//this.find('.elements');
		  
			if (elements.find('a#' + attrs[0]).length > 0) {
			 return;
			}
			
		  var breadcrumb = $('<div/>').addClass('breadcrumb');
			if (this.length != 0) {
        var del = $("<span class='delimitator'>></span>");
        breadcrumb.append(del);
      }
		  breadcrumb.append($('<a></a>').attr('id', attrs[0]).addClass(attrs[1]).attr('href',attrs[2]).text(attrs[3]));
			elements.append(breadcrumb);
		 },

		 resize: function () {
		 	var elements = this.find('.elements');
	    var api = this.data('jsp');

	    var width = 0;
	    elements.children().each(function(){
				width += $(this).outerWidth();
	    });

	    elements.width(width);
	    api.reinitialise();
	    api.scrollByX(width);
		 },

		 update: function () {
		 	var breadcrumbs = this;
		 	var links_to_delete = breadcrumbs.data('to_delete');
			if (links_to_delete != null) {
		    $.each(links_to_delete, function(index, value){
		      var link = breadcrumbs.find('#' + value);
					link.parent().remove();
		    });
				breadcrumbs.removeData('to_delete');
		  }
		 },
		 
		 breadcrumbsToLoad: function(bids) {
		 	if (bids == null) { return []; }
		  /* current bids in stack */
		  var bids_stack = bids.split(",");
			
			
			/* get keys for comparison */
			var bid_keys = $.map(bids_stack, function(a) {
				var aux = a.split('=>');
				return aux[0]!='fq' ? aux[0] : aux[1];
			});
			
			/* current breadcrumb entries */
		  var visible_bids = this.find("a").map(function(){
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
		 
		 getBreadcrumbStack: function(element){
		 	var breadcrumbs = this.find(".breadcrumb a.search_link").map(function(){
				if (this.id == 'sr') {
					return 'sr=>'+ $(this).getUrlParam('search_terms');
				} else
			  {
					return this.id;
				}
			}).get();
			var node_breadcrumbs = this.find(".breadcrumb a.statement").map(function(){
		    return 'fq=>'+ this.id.replace(/[^0-9]+/, '');
		  }).get();
		  $.merge(breadcrumbs, node_breadcrumbs);
			if (element) {
		  	var statement_id = element.parents('.statement').attr('id').replace(/[^0-9]+/, '');
		  	breadcrumbs.push('fq=>' + statement_id);
		  }
			return breadcrumbs;
		}
  };

  $.fn.breadcrumb = function( method ) {
    
		var return_value = null;
    if ( methods[method] ) {
      return_value = methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else if ( typeof method === 'object' || ! method ) {
      methods.init.apply( this, arguments );
    } else {
      $.error( 'Method ' +  method + ' does not exist on jQuery.breadcrumb' );
    }
		return (return_value == null) ? this : return_value;
  };

})( jQuery );
