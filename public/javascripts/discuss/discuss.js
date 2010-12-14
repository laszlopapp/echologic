/* Do init stuff. */
$(document).ready(function () {

	initFragmentStatementChange();

	initBreadcrumbs();

	initFollowUpQuestionHistoryEvents();

	initStatements();

});


function initStatements(){
	$('#statements .statement').livequery(function(){
		$(this).statement();
	});
	initExpandables();
}

function initBreadcrumbs() {
	$('#breadcrumbs').livequery(function(){
		$(this).jScrollPane({animateTo: true});
	});
	$('#breadcrumbs a.statement').livequery(function(){
    $(this).breadcrumb();
  });
}

function initFollowUpQuestionHistoryEvents() {
	/****************************/
  /* FOLLOW-UP QUESTION CHILD */
  /****************************/
  $("#statements .statement #follow_up_questions.children a.statement_link").live("click", function(){
    var question = $(this).parent().attr('id').replace(/[^0-9]+/, '');
    var breadcrumbs = getBreadcrumbStack($(this));

    /* set fragment */
    $.setFragment({
      "bid": breadcrumbs.join(','),
      "sid": question,
      "new_level": true
    });
    return false;
  });
}

function initExpandables(){
	$(".ajax_expandable").livequery(function(){
		var content = $(this).attr('data-content');
		var path = $(this).attr('href');

		$(this).data('content', content);
		$(this).data('path', path);

		$(this).removeAttr('data-content');
		$(this).removeAttr('href');
	});

	/* Special ajax event for the discussion (collapse/expand)*/
	$(".ajax_expandable").live("click", function(){
		element = $(this);
		to_show = element.parents("div:first").find($(this).data('content'));
		if (to_show.length > 0) {
			/* if statement already has loaded content */
			supporters_label = element.find('.supporters_label');
			element.toggleClass('active');
			to_show.animate(toggleParams, 500);
			supporters_label.animate(toggleParams, 500);
		}
		else
		{
			/* load the content that is missing */
			href = $(this).data('path');

			$.getScript(href, function(){
				element.toggleClass('active');
			});
		}
		return false;
	});
}


/* select approved text in the form */
/*function selectApprovedText(id) {
  if (document.selection) document.selection.empty();
  else if (window.getSelection)
          window.getSelection().removeAllRanges();
  if (document.selection) {
    var range = document.body.createTextRange();
        range.moveToElementText(document.getElementById("ip_text"));
    range.select();
    }
    else if (window.getSelection) {
    var range = document.createRange();
    range.selectNode(document.getElementById("ip_text"));
    window.getSelection().addRange(range);
  }
}*/


/********************************/
/* STATEMENT NAVIGATION HISTORY */
/********************************/



function getBreadcrumbStack(element){
	var breadcrumbs = $("#breadcrumbs a.statement").map(function(){
    return this.id.replace(/[^0-9]+/, '');
  }).get();

	var statement_id = element.parents('.statement').attr('id').replace(/[^0-9]+/, '');
	breadcrumbs.push(statement_id);
  return breadcrumbs;
}







function getBreadcrumbsToLoad(bid) {
	if (bid == null) { return []; }
	/* current bid in stack */
	var bid_stack = bid.split(",");
	/* current breadcrumb entries */
	var visible_bid = $("#breadcrumbs a.statement").map(function(){
		return this.id.replace(/[^0-9]+/, '');
  }).get();

	 $.map(visible_bid, function(a) {
	 	if($.inArray(a, bid_stack) == -1) {
			$("#"+a).remove();
		}
	 });

	/* get bid's that are not visible (don't repeat yourself) */
	var bid_to_load = $.grep(bid_stack, function(a){
		return $.inArray(a, visible_bid) == -1 ;});

	return bid_to_load;
}


function initFragmentStatementChange() {
  $(document).bind("fragmentChange.sid", function() {
		if ($.fragment().sid) {
			var sid = $.fragment().sid;
			var new_sid = sid.split(",");

			var path = "/" + new_sid[new_sid.length-1];


			last_sid = new_sid.pop();


			var visible_sid = $("#statements .statement").map(function(){
				return this.id.replace(/[^0-9]+/, '');
			}).get();


			/* after new statement was created and added to the stack, we needn't load again */
			if ($.inArray(last_sid, visible_sid) != -1 && visible_sid[visible_sid.length-1]==last_sid) {return;}

			sid = $.grep(new_sid, function (a) {
				return $.inArray(a, visible_sid) == -1 ;});

			var bid = getBreadcrumbsToLoad($.fragment().bid);


			path = $.queryString(document.location.href.replace(/\/\d+/, path), {
        "sid": sid.join(","),
				"breadcrumb": bid.join(","),
        "new_level": $.fragment().new_level
      })
			$.ajax({
				url:      path,
	      type:     'get',
	      dataType: 'script'
			});
		}
  });

	/* Statement Stack */
  if ($.fragment().sid) {
		$.setFragment({ "new_level" : true });
		$(document).trigger("fragmentChange.sid");
  }


	/* Breadcrumbs */
	if ($.fragment().bid) {
		$(document).trigger("fragmentChange.bid");
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

