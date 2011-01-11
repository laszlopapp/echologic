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
	$('#statements .statement').each(function(){
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
		var bids = $('#breadcrumbs').breadcrumb('getBreadcrumbStack', $(this));
		
		var last_bid = bids[bids.length-1];
		
    /* set fragment */
    $.setFragment({
      "bids": bids.join(','),
      "sids": question,
      "new_level": true,
			"prev": last_bid
    });
    return false;
  });
	
	
	/* NEW FOLLOW-UP QUESTION BUTTON ON CHILDREN */
	$("#statements .statement #follow_up_questions.children a.create_follow_up_question_button").live("click", function(){
    var bids = $('#breadcrumbs').breadcrumb('getBreadcrumbStack', $(this));
    
	  /* set fragment */
    $.setFragment({
      "bids": bids.join(','),
      "new_level": true
    });
  });
	
	$("#statements form.follow_up_question.new a.cancel_text_button").live("click", function(){
		var bids = $('#breadcrumbs').breadcrumb('getBreadcrumbStack', null);
		
		/* get last breadcrumb id */
		var last_bid = bids[bids.length-1].split('=>').pop();
		/* get last statement view id (if teaser, parent id + '/' */
		var last_sid = $.fragment().sids;
		if (last_sid) {
			last_sid = $.fragment().sids.split(',').pop().match(/\d+\/?/).shift();
		} else {
			last_sid = '';
		}
		if (last_bid.match(last_sid)) { /* create follow up question button was pressed */
			var bid_to_delete = $('#breadcrumbs a.statement:last');
			$('#breadcrumbs').data('to_delete', [bid_to_delete.attr('id')]);
			
			/* get previous bid in order to load the proper siblings to session */
			var prev_bid = bid_to_delete.parent().prev().find('a');
			if (prev_bid && prev_bid.hasClass('statement')) {
				prev_bid = "fq=>" + prev_bid.attr('id').match(/\d+/);
			}
			else
			{
				prev_bid = "";
			}
			
			bids.pop();
			$.setFragment({
	      "bids": bids.join(','),
	      "new_level": true,
				"prev": prev_bid
      });
			return false;
		}
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

