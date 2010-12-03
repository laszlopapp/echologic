/* Do init stuff. */
$(document).ready(function () {
	
	addTagButtons();
	
	addTagButtonEvents();
	
	loadMessageBoxes();
	
	loadRTEEditor();
	
	loadStatementAutoComplete();
	
	initExpandables();
	
	loadDefaultText();
	
	cleanDefaultsBeforeSubmit();
	
	initEchoNewStatementButtons();
	
	loadStatementSessions();
	
	initPrevNextButtons();
	
	initChildrenPaginationButton();
	
	initStatementHistoryEvents();
  
  initFragmentStatementChange();
	
	initFormStatementType();
	
	handleStatementFormsSubmit();
	
	initBreadcrumbs();
	
});

/********************************/
/* Statement navigation helpers */
/********************************/

function loadBreadcrumb(type, id, url, value) {
	var breadcrumbs = $('#breadcrumbs');
	var breadcrumb = $('<a></a>');
	breadcrumb.attr('id', type + '_' + id);
	breadcrumb.addClass('statement statement_link ' + type + '_link');
	//if (breadcrumbs.length == 0){breadcrumb.addClass('first');}
	breadcrumb.attr('href',url);
	breadcrumb.text(value);
	
	if (breadcrumbs.length != 0) {
  	breadcrumbs.append($("<span class='delimitator'>></span>"));
  }
	breadcrumbs.append(breadcrumb);
	
}

function deleteBreadcrumbs() {
	var links_to_delete = $('#breadcrumbs').data('to_delete');
	if (links_to_delete != null) {
		$.each(links_to_delete, function(index, value){
			var link = $('#breadcrumbs').find('#' + value);
			link.prev().remove();
			link.remove();
  	});
  	$('#breadcrumbs').removeData('to_delete');
  }
}

function initBreadcrumbs() {
	$('#breadcrumbs').livequery(function(){
		$(this).jScrollPane({animateTo: true});
	});
}

function collapseStatements() {
	$('#statements .statement .header').removeClass('active').addClass('ajax_expandable');
	$('#statements .statement .content').hide('slow');
	$('#statements .statement .header .supporters_label').hide();
};

function collapseStatement(element) {
  element.find('.header').removeClass('active').addClass('ajax_expandable');
  element.find('.content').hide('slow');
  element.find('.supporters_label').hide();
};

function replaceOrInsert(element, template){
	if(element.length > 0) {
		element.replaceWith(template);
	}
  else 
	{
		collapseStatements();
		$('div#statements').append(template);
	}
};

function renderAncestor(ancestor_element, ancestor_html) {
	replaceOrInsert(ancestor_element, ancestor_html);
}

function removeChildrenStatements(element){
	element.nextAll().each(function(){
		/* delete the session data relative to this statement first */
		$('div#statements').removeData(this.id);
		$(this).remove();
	});
};

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
		supporters_label = element.find('.supporters_label'); 
		if (to_show.length > 0) {
			/* if statement already has loaded content */
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


/* Gets the siblings of the loaded statement and places them in the client session for navigation purposes */
function loadStatementSessions() {
	$("#statements div.statement, #statements form.statement").livequery(function(){
		
		parent = $(this).prev();
		if (parent.length > 0)      
    {
      /* stores siblings with the parent node id */
      var parent = parent.attr('id');
    }else{
      /* no parent id, that means it's a root node, therefore, stores them into roots */
      var parent = 'roots';
    }
		siblings = eval($(this).attr("data-siblings"));
		if (siblings != null) {
			$("div#statements").data(parent, siblings);
	  }
		$(this).removeAttr("data-siblings");
	});
}

/* initializes prev/next navigation buttons with the proper url */
function initPrevNextButtons() {
	$("#statements .statement .header a.prev").livequery(function(){
		initNavigationButton(this, -1);
	});
	$("#statements .statement .header a.next").livequery(function(){
    initNavigationButton(this, 1);
  });
}

function initNavigationButton(element, inc) {
	
	current_node_id = $(element).attr('data-id');
	node = $(element).parents('.statement');
	
	if (current_node_id.match('add')) {
		aux = current_node_id.split('_');
		current_node_id = [];
		/* get parent id */  if(aux[0].match(/\d+/)) {current_node_id.push(aux.shift());} 
		/* get 'add' */  current_node_id.push(aux.shift());
		current_node_id.push(aux.join('_')); current_node_id = "/"+current_node_id.join('/');
	} else {current_node_id = eval(current_node_id);}
	/* get current node statement type */
	if (node.attr("id").match('add_')) {
    node_class = node.attr("id").replace('add/','');
  }
  else {
  	node_class = node.attr("id").match(/[a-z]+(?:_[a-z]+)?/);
		node_class = node_class[0].replace('edit_',''); //edit form has prev/next buttons too!!
  }
	/* get parent node from the visited node */
  parent_node = node.prev();
	/* get id where the current node's siblings are stored */
  if(parent_node.length > 0)
  {
		parent_path = parent_node_id = parent_node.attr('id');
	} else {
		parent_node_id = 'roots';
		parent_path = '';
	}
	/* get siblings ids */
	siblings_ids = $("div#statements").data(parent_node_id);
	/* get index of the prev/next sibling */
	id_index = (siblings_ids.indexOf(current_node_id) + inc) % siblings_ids.length;
	//BUG: % operator is not working properly in jquery for negative values (-1%7 => -1)?????????
	if (id_index < 0) {id_index = siblings_ids.length - 1;}
	
  new_node_id = new String(siblings_ids[id_index]);
	/* if 'add' action, then write add link */
	if (new_node_id.match('add')) {
		element.href = element.href.replace(/\/\d+.*/, new_node_id);
	}
	else {
		element.href = element.href.replace(/\/\d+.*/, "/" + new_node_id);
	}
	
  $(element).removeAttr('data-id');
}

/****************/
/* Form Helpers */
/****************/

/* write the default message on the text inputs while they don't get filled */
function loadDefaultText() {
	
	$("#statements form.new input[type='text']").livequery(function(){
		var value = $(this).attr('data-default');
		if (this.value.length == 0) {
			$(this).toggleVal({
				populateFrom: 'custom',
				text: value
			});
		}
		$(this).removeAttr('data-default');
		$(this).blur();
	});
	
	$("#statements form.new iframe.rte_doc").livequery(function(){
		var value = $(this).attr('data-default');
		var doc = $(this).contents().get(0);
		text = $(doc).find('body');
		if(text.html().length == 0 || html.val() == '</br>') {
			label = $("<span class='defaultText'></span>").html(value);
			label.insertAfter($(this));
			
			$(doc).bind('click', function(){
				label.hide();
			});
			$(doc).bind('blur', function(){
				new_text = $(this).find('body');
				if (new_text.html().length == 0 || new_text.html() == '</br>') {
					label.show();
				}
			});
		}
		$(this).removeAttr('data-default');
	});
	
	$("#statements form.new").livequery( function() {
    $(this).bind('submit', (function() {
      $(this).find(".toggleval").each(function() {
        if($(this).val() == $(this).data("defText")) {
          $(this).val("");
        }
      });
    }))
  });
}

/* clean input text fields which might still be filled with the default message */
function cleanDefaultsBeforeSubmit() {
	$('#statements form.statement').livequery(function(){
		$(this).bind('submit', function(){
	    $("input[type='text']", $(this)).each(function() {
	      // If the input still with default value, clean it before the submit
	      if ($(this).val() == $(this).attr('data-default')) {
	        $(this).val('');
	      }
	    });
		});
  });
}

function initEchoNewStatementButtons() {
	$('div#echo_button .new_record.not_supported').live('click', function(){
		initEchoStatementButton($(this),'supported','not_supported','echo_indicator','no_echo_indicator',10,'1',true)
	});
	$('div#echo_button .new_record.supported').live('click', function(){
		initEchoStatementButton($(this),'not_supported','supported','no_echo_indicator','echo_indicator',0,'0',false)
  });
}

function initEchoStatementButton(element, class_add, class_remove, ratio_class_add, ratio_class_remove, ratio, supporters_number, value) {
	page = element.parents('form.statement');
	/* modify echo button in element */
	element.removeClass(class_remove).addClass(class_add);
	
  /* modify text in supporters label */
  page.find('#echo').val(value);
	supporters_label = page.find('.supporters_label');
  supporters_text = supporters_label.text();
  supporters_label.text(supporters_text.replace(/[0-9]/, supporters_number));
	
	/* modify the supporters bar */
	old_supporter_bar = page.find('.supporters_bar');
  new_supporter_bar = $('<span></span>').attr('class', old_supporter_bar.attr('class')).addClass(ratio_class_add).removeClass(ratio_class_remove).attr('alt', ratio);
	new_supporter_bar.attr('title', page.find('.supporters_label').text());
	old_supporter_bar.replaceWith(new_supporter_bar);
	info(page.find('.action_bar').data('messages')[class_add]);
}


function handleStatementFormsSubmit() {
	$('#statements form.new').livequery(function(){
		var form = this;
		element = $(this);
    element.bind('submit', (function(){
			showNewStatementType(form);
			$.ajax({
			  url: this.action,
				type: "POST",
				data: $(this).serialize(),
			  dataType: 'script',
        success: function(data, status){
          hideNewStatementType(form);
        }
      });
      return false;
    }));
  })
}

function hideNewStatementType(element) {
	input_type = $(element).find('input#type');
	input_type.data('value',input_type.attr('value'));
  input_type.removeAttr('value');
}

function showNewStatementType(element) {
  input_type = $(element).find('input#type');
	input_type.attr('value', input_type.data('value'));
}

/**************************/
/* Discussion Tag Helpers */
/**************************/


/* load the previously existing tags */
function addTagButtons() {
  $('form.taggable').livequery(function(){
		tags_to_load = $(this).find('input.discussion_tags').val();
    tags_to_load = $.trim(tags_to_load);
    tags_to_load = tags_to_load.split(',');
    while (tags_to_load.length > 0) {
      tag = $.trim(tags_to_load.shift());
      if (tag.localeCompare(' ') > 0) {
        element = createTagButton(tag, $(this).find(".discussion_tags"));
        $(this).find('#discussion_tags_values').append(element);
      }
    }
  });
}
/* add new tags to be added to statement */
function addTagButtonEvents() {
  $('#statements form.statement #tag_topic_id').live('keypress', (function(event) {
		statement = $(this).parents('form.statement'); 
    if (event && event.keyCode == 13) { /* check if enter was pressed */
      if (statement.find('#tag_topic_id').val().length != 0) {
        statement.find('.addTag').click();
      }
      return false;
    }
  }));

  $('#statements form.statement .addTag').live('click', (function() {
		statement = $(this).parents('form.statement');
    entered_tags = statement.find('#tag_topic_id').val().trim().split(",");
    if (entered_tags.length != 0) {
      /* Trimming all tags */
      entered_tags = jQuery.map(entered_tags, function(tag) {
        return (tag.trim());
      });
			existing_tags = statement.find('.discussion_tags').val();
			existing_tags = existing_tags.split(',');
			existing_tags = $.map(existing_tags,function(q){return q.trim()});

      new_tags = new Array(0);
      while (entered_tags.length > 0) {
        tag = entered_tags.shift().trim();
        if (existing_tags.indexOf(tag) < 0 && entered_tags.indexOf(tag) < 0) {
          if (tag.localeCompare(' ') > 0) {
            element = createTagButton(tag, ".discussion_tags");
            $('#discussion_tags_values').append(element);
            new_tags.push(tag);
          }
        }
      }
      discussion_tags = statement.find('.discussion_tags').val();
      if (new_tags.length > 0) {
        discussion_tags = ((discussion_tags.trim().length > 0) ? discussion_tags + ',' : '') + new_tags.join(',');
        statement.find('.discussion_tags').val(discussion_tags);
      }
      statement.find('#tag_topic_id').val('');
      statement.find('#tag_topic_id').focus();
    }
  }));
}

/* creates a statement tag button */
function createTagButton(text, tags_id) {
  element = $('<span/>').addClass('tag');
  element.text(text);
  deleteButton = $('<span class="delete_tag_button"></span>');
  deleteButton.click(function(){
    $(this).parent().remove();
    tag_to_delete = $(this).parent().text();
		discussion_tags = tags_id.val();
		discussion_tags = discussion_tags.split(',');
		discussion_tags = $.map(discussion_tags,function(q){return q.trim()});
		index_to_delete = discussion_tags.indexOf(tag_to_delete);
		if (index_to_delete >= 0) {
      discussion_tags.splice(index_to_delete, 1);
    }
		
    $("#"+tags_id.attr('id')).val(discussion_tags.join(','));
  });
  element.append(deleteButton);
  return element;
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

/*************************/
/* Delayed Message Boxes */
/*************************/

var timer = null;
function loadMessageBoxes() {
	$('#statements .statement .message_box').livequery(function(){
		element = $(this);
		if (timer != null) {
      clearTimeout (timer);
      element.stop(true).hide;
    }
		timer = setTimeout( function(){
		  element.animate(toggleParams, 500);
		}, 1500);
	});
}

/*********************/
/* RTE Editor loader */
/*********************/

/* lwRTE editor loading */
function loadRTEEditor() {
	$('textarea.rte_doc, textarea.rte_tr_doc').livequery(function(){
		defaultText = $(this).attr('data-default');
		
		parent_node = $(this).parents('.statement');
	  url = 'http://' + window.location.hostname + '/stylesheets/';
	  $(this).rte({
	    css: ['jquery.rte.css'],
	    base_url: url,
	    frame_class: 'wysiwyg',
	    controls_rte: rte_toolbar,
	    controls_html: html_toolbar
	  });
		parent_node.find('.focus').focus();
		
		/* for default text */
		parent_node.find('iframe').attr('data-default', defaultText);
	});
}

/********************************/
/* STATEMENT NAVIGATION HISTORY */
/********************************/

function getCurrentStatementsStack(element, new_level) {
	/* get the statement element */
	var statement = $(element).parents('.statement');
	/* get statement id current index in the list of statements */
  var statement_index = $('#statements .statement').index(statement);
	
	/* get soon to be visible statement */
  var path = element.href.split("/");
	var id = path.pop().split('?').shift();
	
	if (id.match(/\d+/)) {
  	var current_sid = id;
  } else {
		/* add teaser case */
		/* when there's a parent id attached, copy :id/add/:type, or else, just copy the add/:type */
		var index_backwards = path[path.length - 2].match(/\d+/) ? 2 : 1;
		var current_sid = path.splice(path.length - index_backwards, 2);
		current_sid.push(id);
		current_sid = current_sid.join('/');
	}
  current_stack = [];
	
	/* get current_stack of visible statements (if any matches the clicked statement, then break) */
  $("#statements .statement").each( function(index){
		if (index < statement_index) {
			id = $(this).attr('id').split('_').pop();
			if(id.match("add")){
				id = "add/" + id;
			}
			current_stack.push(id);
		} else if (index == statement_index) {
			 if (new_level) {
			 	current_stack.push($(this).attr('id').split('_').pop());
			 }
		  }
  });
  /* insert clicked statement */
  current_stack.push(current_sid);
	return current_stack;
}

function getBreadcrumbStack(element){
	var breadcrumbs = $("#breadcrumbs a.statement").map(function(){
    return this.id.replace(/[^0-9]+/, '');
  }).get();
  
	var statement_id = element.parents('.statement').attr('id').replace(/[^0-9]+/, '');
	breadcrumbs.push(statement_id);
  return breadcrumbs;
}


function initStatementHistoryEvents() {
	/********************/
	/* NEXT/PREV, TITLE */
	/********************/
	$("#statements .statement .header a.statement_link").live("click", function(){
		current_stack = getCurrentStatementsStack(this, false);
		/* set fragment */
		$.setFragment({ "sid": current_stack.join(','), "new_level" : ''});
		return false;
	});
	
	/****************************/
  /* FOLLOW-UP QUESTION CHILD */
  /****************************/
	$("#statements .statement #follow_up_questions.children a.statement_link").live("click", function(){
    var question = $(this).parent().attr('id').replace(/[^0-9]+/, '');
		var breadcrumbs = getBreadcrumbStack($(this));
		
    /* set fragment */
    $.setFragment({"bid": breadcrumbs.join(','), "sid": question, "new_level" : true});
    return false;
  });
	
	/*******************/
  /* STATEMENT CHILD */
  /*******************/
	$("#statements .statement .children a.statement_link").live("click", function(){
    current_stack = getCurrentStatementsStack(this, true);
		/* set fragment */
    $.setFragment({ "sid": current_stack.join(','), "new_level" : true});
		return false;
  });
	
	
	/*******************************/
  /* NEW STATEMENT CANCEL BUTTON */
  /*******************************/
	$("#statements form.statement.new .buttons a.cancel").livequery(function(){
		if ($.fragment().sid) {
			var sid = $.fragment().sid;
			var path = getStatementStackPath($.fragment().sid);
      var new_sid = sid.split(",");
			new_sid.pop();
			
			$(this).addClass("ajax");
			this.href = $.queryString(this.href.replace(/\/\d+/,path), {
				"sid": new_sid.join(","),
				"new_level": ''
			})
		}
	});
	/*******************/
  /* BREADCRUMB LINK */
  /*******************/
	
	/*loads statement stack of ids into the button itself */
	$("#breadcrumbs a.statement").livequery(function(){
		var path_id = this.href.match(/\/\d+/);
		var path = this.href.replace(/\/\d+.*/, path_id + '/' + 'parents');
		var element = $(this);
		$.getJSON(path, function(data) {
		  var sid = data;
			element.data('sid', sid);
		});
	});
	
	
	$("#breadcrumbs a.statement").live("click", function(){
		/* get bids from fragment */
		var bid = $.fragment().bid;
		bid = (bid == null) ? [] : bid.split(','); 
		
		/* get links that must vanish from the breadcrumbs */
    var links_to_delete = $(this).nextAll(".statement").map(function(){
	    return this.id;
	  }).get();
		links_to_delete.push($(this).attr('id'));
		
		/* set new bids to save in fragment */
		id_links_to_delete = $.map(links_to_delete, function(a){
			return a.replace(/[^0-9]+/, '');
		});
		new_bid = $.grep(bid, function(a){
			return $.inArray(a, id_links_to_delete) == -1;
		});
		/* save them to be deleted after the request */
		$("#breadcrumbs").data('to_delete', links_to_delete);
		/* set fragment */
		var sid = $(this).data('sid');
    $.setFragment({"bid" : new_bid.join(","), "sid": sid.join(","), "new_level" : ''});
    return false;
  });
}

function getStatementStackPath(stack) {
	var stack = stack.split(",");
  return "/" + stack.pop();
}

function getBreadcrumbsToLoad(bid) {
	if (bid == null) { return []; }
	/* current bid in stack */
	var bid_stack = bid.split(",");
	/* current breadcrumb entries */
	var visible_bid = $("#breadcrumbs a.statement").map(function(){
		var id = this.id.replace(/[^0-9]+/, '');
		/*if($.inArray(id, bid_stack) == -1) {
			$(this).prev().remove();
      $(this).remove();
    }*/
    return id;
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
			var path = getStatementStackPath(sid);
			var new_sid = sid.split(",");
			
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

function initChildrenPaginationButton() {
  $("#statements .statement .more_pagination a").live("click", function() {
    $(this).replaceWith($('<span/>').text($(this).text()).addClass('more_loading'));
  });
}


function pagination_scroll_down(element) {
  element.jScrollPane({animateTo: true});
  if (element.data('jScrollPanePosition') != element.data('jScrollPaneMaxScroll')) {
    element[0].scrollTo(element.data('jScrollPaneMaxScroll'));
  }

}


/***********/
/* GENERAL */
/***********/

function loadStatementAutoComplete() {
	$('#statements form.statement .tag_value_autocomplete').livequery(function(){
		$(this).autocomplete('../../discuss/auto_complete_for_tag_value', {minChars: 3, selectFirst: false});
	});
}

function loadMessages(element, messages) {
	$(element).data('messages', messages);
}

function initFormStatementType() {
	$("#statements form.new").livequery(function(){
	 hideNewStatementType(this);
	});
}


