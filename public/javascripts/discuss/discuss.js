/* Do init stuff. */

/* Initialization on loading the document */
$(document).ready(function () {
	initFragmentStatementChange();
	initBreadcrumbs();
	initFollowUpQuestionHistoryEvents();
	initStatements();
  initExpandables();
	
});


function initStatements() {
	$('#statements .statement').livequery(function(){
		$(this).statement();
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

function initFollowUpQuestionHistoryEvents() {

  /* FOLLOW-UP QUESTION CHILD */
  $("#statements .statement #follow_up_questions.children a.statement_link").live("click", function(){
    var question = $(this).parent().attr('id').replace(/[^0-9]+/, '');
    var bids = getBreadcrumbStack($(this));
		bids.push(question);
		
    /* set fragment */
    $.setFragment({
      "bids": bids.join(','),
      "sids": question,
      "new_level": true
    });
    return false;
  });
	
	$("#statements .statement #follow_up_questions.children a.create_follow_up_question_button").live("click", function(){
    var bids = getBreadcrumbStack($(this));
    
    /* set fragment */
    $.setFragment({
      "bids": bids.join(','),
      "new_level": true
    });
  });
	
	$("#statements form.follow_up_question.new a.cancel_text_button").live("click", function(){
		bid_to_delete = $('#breadcrumbs a.statement:last').attr('id');
		$('#breadcrumbs').data('to_delete', [bid_to_delete]);
	});
}

function initExpandables() {
	$(".ajax_expandable").livequery(function(){
		var content = $(this).attr('data-content');
		var path = $(this).attr('href');

		$(this).data('content', content);
		$(this).data('path', path);

		$(this).removeAttr('data-content');
		$(this).removeAttr('href');
	});

	/* Special ajax event for the statement (collapse/expand)*/
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


function getBreadcrumbsToLoad(bids) {
	if (bids == null) { return []; }
	/* current bids in stack */
	var bids_stack = bids.split(",");
	/* current breadcrumb entries */
	var visible_bids = $("#breadcrumbs a.statement").map(function(){
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
}


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

			var bids = getBreadcrumbsToLoad($.fragment().bids);


			path = $.queryString(document.location.href.replace(/\/\d+/, path), {
        "sids": sids.join(","),
				"bids": bids.join(","),
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
  if ($.fragment().sids) {
		$.setFragment({ "new_level" : true });
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

