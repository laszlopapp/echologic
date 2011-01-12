/* Do init stuff. */

/* Initialization on loading the document */
$(document).ready(function () {
	initFragmentStatementChange();
	initBreadcrumbs();
	initStatements();

});


function initStatements() {
	$('#statements .statement').each(function(){
		$(this).statement({'insertStatement' : false});
	});
}

function initBreadcrumbs() {
	$('#breadcrumbs').livequery(function(){
		$(this).jScrollPane({animateTo: true});
	});
	$('#breadcrumbs a.statement').livequery(function(){
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

      var bids = $("#breadcrumbs").breadcrumb('breadcrumbsToLoad', $.fragment().bids);

			path = $.queryString(document.location.href.replace(/\/\d+/, path), {
        "sids": sids.join(","),
				"bids": bids.join(","),
        "new_level": $.fragment().new_level,
				"prev": $.fragment().prev
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
			var bids = $("#breadcrumbs").breadcrumb('getBreadcrumbStack', null).join(',');}
		else {var bids = $.fragment().bids;}

		if (!$.fragment().prev || $.fragment().prev == 'undefined') {var prev = '';}
		else {var prev = $.fragment().prev;}

		$.setFragment({ "new_level" : true, "bids" : bids, "prev" : prev });
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
	list.animate(properties, 400, function() {
    list.jScrollPane({animateScroll: true});
  });
}

