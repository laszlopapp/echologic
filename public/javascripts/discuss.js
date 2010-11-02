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
		$('#statements').append(template);
	}
};

function removeChildrenStatements(element){
	element.nextAll().remove();
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
	
	$(".question .header_buttons a").live("click", function(event){
		window.location = this.href;
		return false;
	});
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
	})
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

/************************/
/* Question Tag Helpers */
/************************/

/* add new tags to be added to statement */
function addTagButtonEvents() {
  $('.question #tag_topic_id').live('keypress', (function(event) {
    if (event && event.keyCode == 13) { /* check if enter was pressed */
      if ($('.question #tag_topic_id').val().length != 0) {
        $('.question .addTag').click();
      }
      return false;
    }
  }));

  $('.question .addTag').live('click', (function() {
    entered_tags = $('.question #tag_topic_id').val().trim().split(",");
    if (entered_tags.length != 0) {
      /* Trimming all tags */
      entered_tags = jQuery.map(entered_tags, function(tag) {
        return (tag.trim());
      });
      existing_tags = $('.question #question_tags').val().trim();
      existing_tags = existing_tags.split(',');

      new_tags = new Array(0);
      while (entered_tags.length > 0) {
        tag = entered_tags.shift().trim();
        if (existing_tags.indexOf(tag) < 0 && entered_tags.indexOf(tag) < 0) {
          if (tag.localeCompare(' ') > 0) {
            element = createTagButton(tag, "#question_tags");
            $('#question_tags_values').append(element);
            new_tags.push(tag);
          }
        }
      }
      question_tags = $('.question #question_tags').val();
      if (new_tags.length > 0) {
        question_tags = ((question_tags.trim().length > 0) ? question_tags + ',' : '') + new_tags.join(',');
        $('.question #question_tags').val(question_tags);
      }
      $('.question #tag_topic_id').val('');
      $('.question #tag_topic_id').focus();
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
    question_tags = $(tags_id).val().split(',');
    index_to_delete = question_tags.indexOf(tag_to_delete);
    if (index_to_delete >= 0) {
      question_tags.splice(index_to_delete, 1);
    }
    $('form.question').find(tags_id).val(question_tags.join(','));
  });
  element.append(deleteButton);
  return element;
}

/* load the previously existing tags */
function addTagButtons() {
	$('form.question.new, form.question.edit').livequery(function(){
	  tags_to_load = $('#question_tags').val().trim().split(',');
	  while (tags_to_load.length > 0) {
	    tag = tags_to_load.shift().trim();
	    if (tag.localeCompare(' ') > 0) {
	      element = createTagButton(tag, "#question_tags");
	      $(this).find('#question_tags_values').append(element);
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
