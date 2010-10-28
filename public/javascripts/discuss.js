/* Do init stuff. */
$(document).ready(function () {
	
	addTagButtonEvents();
	
	addTagButtons();
	
	loadMessageBoxes();
	
	loadRTEEditor();
	
	loadStatementAutoComplete();
	
});

/********************************/
/* Statement navigation helpers */
/********************************/

function collapseStatements() {
	$('#statements .statement .header').removeClass('active');
	$('#statements .statement .content').hide();
	$('#statements .statement .supporters_label').hide();
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
