/* Do init stuff. */

/* Initialization on loading the document */
$(document).ready(function () {
	initBreadcrumbs();
	initStatements();
	initFragmentStatementChange();
});


function initStatements(){
	var sids = [];
	$('#statements .statement').each(function(){
		$(this).statement({'insertStatement': false});
		if ($(this).is("div")) {
			sids.push($(this).attr('id').match(/\d+/));
		}
	});
	if (sids.length > 0 && (!$.fragment().sids || $.fragment().sids.length == 0)) {
  	$.setFragment({
  		"sids": sids.join(",")
  	});
  }
}

function initBreadcrumbs() {
	$('#breadcrumbs').each(function(){
		$(this).jScrollPane({animateTo: true});
		$(this).breadcrumb();
	});
}

/********************************/
/* STATEMENT NAVIGATION HISTORY */
/********************************/

function initFragmentStatementChange() {
	$(document).bind("fragmentChange.sids", function() {
		if ($.fragment().sids) {
			var sids = $.fragment().sids;
			var new_sids = sids.split(",");

			var path = "/" + new_sids[new_sids.length-1];


			last_sids = new_sids.pop();


			var visible_sids = $("#statements .statement").map(function(){
				return this.id.replace(/[^0-9]+/, '');
			}).get();


			/* after new statement was created and added to the stack, we needn't load again */
			if ($.inArray(last_sids, visible_sids) != -1 && visible_sids[visible_sids.length-1]==last_sids) {return;}

			sids = $.grep(new_sids, function (a) {
				return $.inArray(a, visible_sids) == -1 ;});

      var bids = $("#breadcrumbs").data('api').breadcrumbsToLoad($.fragment().bids);
			
			path = $.queryString(document.location.href.replace(/\/\d+/, path), {
        "sids": sids.join(","),
				"bids": bids.join(","),
        "new_level": $.fragment().new_level,
				"origin": $.fragment().origin
      });

			$.ajax({
				url:      path,
	      type:     'get',
	      dataType: 'script'
			});
		}
  });

	/* Statement Stack */
  if ($.fragment().sids) {
		if (!$.fragment().bids || $.fragment().bids == 'undefined') {
			var bids = $("#breadcrumbs").data('api').getBreadcrumbStack(null).join(',');}
		else {var bids = $.fragment().bids;}
      
		if (!$.fragment().origin || $.fragment().origin == 'undefined') {var origin = bids.split(',').pop();}
		else {var origin = $.fragment().origin;}

		$.setFragment({ "new_level" : true, "bids" : bids, "origin" : origin });
	  $(document).trigger("fragmentChange.sids");
  }


	/* Breadcrumbs */
	if ($.fragment().bids) {
		$(document).trigger("fragmentChange.bids");
	}
}

/*********************************************/
/*    CHILDREN PAGINATION AND SCROLLING      */
/*********************************************/



function resetChildrenList(list, properties) {
	list.animate(properties, 300, function() {
    list.jScrollPane({animateScroll: true});
  });
}

