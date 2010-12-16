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
	    var bids = $.fragment().bids;
	    bids = (bids == null) ? [] : bids.split(',');

	    /* get links that must vanish from the breadcrumbs */
	    var links_to_delete = $(this).nextAll(".statement").map(function(){
	      return this.id;
	    }).get();
	    links_to_delete.push($(this).attr('id'));

	    /* set new bids to save in fragment */
	    id_links_to_delete = $.map(links_to_delete, function(a){
	      return a.replace(/[^0-9]+/, '');
	    });
	    new_bids = $.grep(bids, function(a){
	      return $.inArray(a, id_links_to_delete) == -1;
	    });
	    /* save them to be deleted after the request */
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
		 add : function (attrs) { /* Array: [type, id, url, value] */
		  var api = this.data('jsp');
		  var elements = api.getContentPane().find(".elements");//this.find('.elements');
		  var breadcrumb = $('<div/>').addClass('breadcrumb');
			if (this.length != 0) {
        var del = $("<span class='delimitator'>></span>");
        breadcrumb.append(del);
      }
		  breadcrumb.append($('<a></a>').addClass('statement statement_link ' + attrs[0] + '_link')
			                             .attr('id', attrs[0] + '_' + attrs[1])
			                             .attr('href',attrs[2]).text(attrs[3]));
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
		    this.removeData('to_delete');
		  }
		 },
		 
		 breadcrumbsToLoad: function(bids) {
		 	if (bids == null) { return []; }
		  /* current bids in stack */
		  var bids_stack = bids.split(",");
		  /* current breadcrumb entries */
		  var visible_bids = this.find("a.statement").map(function(){
		    return this.id.replace(/[^0-9]+/, '');
		  }).get();
		
	    $.map(visible_bids, function(a) {
	     if($.inArray(a, bids_stack) == -1) {
	       $("#"+a).remove();
	     }
	    });
		
		  /* get bids that are not visible (don't repeat yourself) */
		  var bids_to_load = $.grep(bids_stack, function(a){
		    return $.inArray(a, visible_bids) == -1 ;});
		
		  return bids_to_load;
		 },
		 
		 getBreadcrumbStack: function(element){
		  var breadcrumbs = this.find("a.statement").map(function(){
		    return this.id.replace(/[^0-9]+/, '');
		  }).get();
		
		  var statement_id = element.parents('.statement').attr('id').replace(/[^0-9]+/, '');
		  breadcrumbs.push(statement_id);
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
