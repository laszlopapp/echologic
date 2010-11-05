/* Do init stuff. */
$(document).ready(function () {
	
	addTagButtonEvents();
	
	addTagButtons();
	
	loadMessageBoxes();
	
	loadRTEEditor();
	
	loadStatementAutoComplete();
	
	initExpandables();
	
	loadTitleDefaultText();
	
	cleanDefaultsBeforeSubmit();
	
	initEchoNewStatementButtons();
	
	loadStatementSessions();
	
	initPrevNextButtons();
	
	initChildrenPaginationButton();
	
});

/********************************/
/* Statement navigation helpers */
/********************************/

function collapseStatements() {
	$('#statements .statement .header').removeClass('active').addClass('ajax_display');
	$('#statements .statement .content').hide('slow');
	$('#statements .statement .header .supporters_bar');
	$('#statements .statement .header .supporters_label').hide();
};

function replaceOrInsert(element, template){
	if(element.length > 0) {
		element.replaceWith(template);
	}
  else 
	{
		$('div#statements').append(template);
	}
};

function removeChildrenStatements(element){
	element.nextAll().each(function(){
		/* delete the session data relative to this statement first */
		$('div#statements').removeData(this.id);
		$(this).remove();
	});
};

function initExpandables(){
	/* Special ajax event for the discussion (collapse/expand)*/
	$(".ajax_display").live("click", function(){
		$(this).toggleClass('active');
		to_show = $(this).parents(".statement").find($(this).attr("data-show"));
		supporters_label = $(this).find('.supporters_label'); 
		if (to_show.length > 0) {
			to_show.animate(toggleParams, 500);
			supporters_label.animate(toggleParams, 500);
		}
		else {
			href = this.href;
			if (href == null) {
				href = $(this).attr('href')
			}
			$.getScript(href + '?expand=true');
		}
		return false;
	});
	
	$(".discussion .header_buttons a").live("click", function(event){
		window.location = this.href;
		return false;
	});
}


/* Gets the siblings of the loaded statement and places them in the client session for navigation purposes */
function loadStatementSessions() {
	$("div.statement").livequery(function(){
		siblings = $(this).attr("data-siblings");
		if (siblings.length > 0) {
			parent = $(this).prev();
			if (parent.length > 0)			
			{
				/* stores siblings with the parent node id */
				parent = parent.attr('id');
			}else{
				/* no parent id, that means it's a root node, therefore, stores them into roots */
				parent = 'roots';
			}
			$("div#statements").data(parent,eval(siblings));
		}
		$(this).removeAttr("data-siblings");
	});
}

/* initializes prev/next navigation buttons with the proper url */
function initPrevNextButtons() {
	$(".statement .header a.prev").livequery(function(){
		initNavigationButton(this, -1);
	});
	$(".statement .header a.next").livequery(function(){
    initNavigationButton(this, 1);
  });
}

function initNavigationButton(element, inc) {
	current_node_id = eval($(element).attr('data-id'));
	node = $(element).parents('.statement');
  parent_node = node.prev();
	/* get id where the current node's siblings are stored */
  if(parent_node.length > 0)
  {
		parent_node_id = parent_node.attr('id');
	} else {
		parent_node_id = 'roots';
	}
  parent_ids = $("div#statements").data(parent_node_id);
	if ($(element).hasClass('add')) {
		/* Add teaser section buttons */
  	if (inc < 0) { id_index = parent_ids.length - 1; }
  	else { id_index = 0; }
  }
  else {
  	/* get index of the prev/next sibling (according to inc) */
	  id_index = parent_ids.indexOf(current_node_id) + inc;
	}
	/* if index out of bounds, than request 'add' action */
	if (id_index < 0 || id_index >= parent_ids.length) {
		element.href = element.href + '/add';
	}
	else {
		id = parent_ids[id_index];
		element.href = element.href.replace(/\/[0-9]+/, "/" + id);
	}
	
  $(element).removeAttr('data-id');
}

/****************/
/* Form Helpers */
/****************/

/* write the default message on the text inputs while they don't get filled */
function loadTitleDefaultText() {
	$("form.new input[type='text']").livequery(function(){
		var value = $(this).attr('data-default');
		
		if (this.value.length == 0) {
			this.value = value;
			$(this).css("color", '#ccc');
		}
		$(this).focus(function() {
	    if (this.value == value) {
	      this.value = '';
	      this.style.color = '#000';
	    }
	    $(this).blur(function() {
	      if (this.value == '') {
		      this.style.color = '#ccc';
	        this.value = value;
	      }
	    });
			$(this).parents('form.new').find('li:commit input').focus();
			$(this).blur();
	  });
		$(this).keypress(function(){
      if(this.value == value) {
        this.style.color = '#000';
        this.value = '';
      }
    });
	});
}

/* clean input text fields which might still be filled with the default message */
function cleanDefaultsBeforeSubmit() {
	$('form.statement').livequery(function(){
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

/**************************/
/* Discussion Tag Helpers */
/**************************/

/* add new tags to be added to statement */
function addTagButtonEvents() {
  $('.discussion #tag_topic_id').live('keypress', (function(event) {
    if (event && event.keyCode == 13) { /* check if enter was pressed */
      if ($('.discussion #tag_topic_id').val().length != 0) {
        $('.discussion .addTag').click();
      }
      return false;
    }
  }));

  $('.discussion .addTag').live('click', (function() {
    entered_tags = $('.discussion #tag_topic_id').val().trim().split(",");
    if (entered_tags.length != 0) {
      /* Trimming all tags */
      entered_tags = jQuery.map(entered_tags, function(tag) {
        return (tag.trim());
      });
      existing_tags = $('.discussion #discussion_tags').val().trim();
      existing_tags = existing_tags.split(',');

      new_tags = new Array(0);
      while (entered_tags.length > 0) {
        tag = entered_tags.shift().trim();
        if (existing_tags.indexOf(tag) < 0 && entered_tags.indexOf(tag) < 0) {
          if (tag.localeCompare(' ') > 0) {
            element = createTagButton(tag, "#discussion_tags");
            $('#discussion_tags_values').append(element);
            new_tags.push(tag);
          }
        }
      }
      discussion_tags = $('.discussion #discussion_tags').val();
      if (new_tags.length > 0) {
        discussion_tags = ((discussion_tags.trim().length > 0) ? discussion + ',' : '') + new_tags.join(',');
        $('.discussion #discussion_tags').val(discussion_tags);
      }
      $('.discussion #tag_topic_id').val('');
      $('.discussion #tag_topic_id').focus();
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
    discussion_tags = $(tags_id).val().split(',');
    index_to_delete = discussion_tags.indexOf(tag_to_delete);
    if (index_to_delete >= 0) {
      discussion_tags.splice(index_to_delete, 1);
    }
    $('form.discussion').find(tags_id).val(discussion_tags.join(','));
  });
  element.append(deleteButton);
  return element;
}

/* load the previously existing tags */
function addTagButtons() {
	$('form.discussion.new, form.discussion.edit').livequery(function(){
	  tags_to_load = $('#discussion_tags').val().trim().split(',');
	  while (tags_to_load.length > 0) {
	    tag = tags_to_load.shift().trim();
	    if (tag.localeCompare(' ') > 0) {
	      element = createTagButton(tag, "#discussion_tags");
	      $(this).find('#discussion_tags_values').append(element);
	    }
	  }
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

/*************************/
/* Delayed Message Boxes */
/*************************/

var timer = null;
function loadMessageBoxes() {
	$('.statement .message_box').livequery(function(){
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
	});
}



/*********************************************/
/*    CHILDREN PAGINATION AND SCROLLING      */
/*********************************************/

function initChildrenPaginationButton() {
  $(".more_pagination a").live("click", function() {
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
	$('form.statement .tag_value_autocomplete').livequery(function(){
		$(this).autocomplete('../../discuss/auto_complete_for_tag_value', {minChars: 3, selectFirst: false});
	});
}

function loadMessages(element, messages) {
	$(element).data('messages', messages);
}
