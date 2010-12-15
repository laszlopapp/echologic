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
		  var elements = this.find('.elements');
		  var breadcrumb = $('<a></a>').attr('id', attrs[0] + '_' + attrs[1]).addClass('statement statement_link ' + attrs[0] + '_link')
			                             .attr('href',attrs[2]).text(attrs[3]);

		  if (this.length != 0) {
		    var del = $("<span class='delimitator'>></span>");
		    elements.append(del);
		  }
		  elements.append(breadcrumb);
		 },

		 resize: function () {
		 	var elements = this.find('.elements');
	    var api = this.data('jsp');

	    var width = 0;
	    elements.children().each(function(){
	      width += $(this).width() + parseInt($(this).css('padding-right')) + parseInt($(this).css('padding-left'));
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
		      link.prev().remove();
		      link.remove();
		    });
		    this.removeData('to_delete');
		  }
		 }
  };

  $.fn.breadcrumb = function( method ) {

    if ( methods[method] ) {
      methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else if ( typeof method === 'object' || ! method ) {
      methods.init.apply( this, arguments );
    } else {
      $.error( 'Method ' +  method + ' does not exist on jQuery.breadcrumb' );
    }
    return this;
  };

})( jQuery );
