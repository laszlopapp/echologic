// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


/* Do init stuff. */
$(document).ready(function () {

  makeTooltips();

  bindLanguageSelectionEvents();

  bindMoreHideButtonEvents();

	bindAddTagButtonEvents();

  bindStaticMenuClickEvents();

  bindAjaxClickEvents();

  roundCorners();



  /* Always send the authenticity_token with ajax */
  $(document).ajaxSend(function(event, request, settings) {
    if ( settings.type == 'post' ) {
      settings.data = (settings.data ? settings.data + "&" : "")
      + "authenticity_token=" + encodeURIComponent( AUTH_TOKEN );
    }
  });

  $('#user_session_email').focus();

  $('.autogrow').autogrow();

});

/* TODO optimize splitting of url! */
/* TODO action set checking */
/* Sets the fragment to the controller and action of the anchors href attribute. */
function setActionControllerFragment(href) {
  controller = href.toString().split('/')[4];
  action = href.toString().split('/')[5];
  if (href.toString().split('/')[5]) {
      document.location.hash = '/' + controller + '/' + action;
  } else {
      document.location.hash = '/' + controller;
  }
}

/* TODO: unobtrusive check */
function bindAjaxClickEvents() {
  $(".ajaxLink").live("click", function() {
    setActionControllerFragment(this.href);
    return false;
  });

  $("#static_menu a").live("click", function() {
    setActionControllerFragment(this.href);
    return false;
  });

  $(".ajax").live("click", function() {
    $.getScript(this.href);
    return false;
  });

  $(".ajax_delete").live("click", function() {
    $.ajax({
      url:      this.href,
      type:     'post',
      dataType: 'script',
      data:   { '_method': 'delete' }
    });
    return false;
  });

  $(".ajax_put").live("click", function() {
    $.ajax({
      url:      this.href,
      type:     'post',
      dataType: 'script',
      data:   { '_method': 'put' }
    });
    return false;
  });

	/*special newsletter submission tag*/
	$(".newsletter_submit_tag").live("click", function() {
		$("#newsletter_test").val($(this).attr("value"));
		$("#new_newsletter_form").submit();
    return false;
  });

}

/* If JS is enabled hijack staticMenuButtons to do AJAX requests. */
function bindStaticMenuClickEvents() {
  $(".staticMenuButton").live("click", function() {
    setActionControllerFragment(this.href);
    return false;
  });

  $(".outerMenuItem").live("click", function() {
    $.getScript(this.href);
    return false;
  });

  $(".prevNextButton").live("click", function() {
    setActionControllerFragment(this.href);
    return false;
  });

  $(".illustrationHolder a").live("click", function() {
    setActionControllerFragment(this.href);
    return false;
  });
}



/* Toggle more text on click, use toggleParams. */
/* IE7 compatibility through IE8.js plugin. */
function bindMoreHideButtonEvents() {
  $('.moreButton').click(function() {
    $(this).next().animate(toggleParams, 300);
    $(this).hide();
    $(this).prev().show();
  });

  $('.hideButton').click(function() {
    $(this).next().next().animate(toggleParams, 300);
    $(this).hide();
    $(this).next().show();
  });
}

/* Show and hide language selection on mouse enter and mouse leave. */
function bindLanguageSelectionEvents() {
  $('#echo_language_button').bind("mouseenter", function() {
    var pos = $("#echo_language_button").position();
    $("#language_selector").css( { "left": (pos.left + 20) + "px", "top": (pos.top + 35) + "px" } );
    $('#language_selector').show();
  });

  $('#language_selector').bind("mouseleave", function() {
    $('#language_selector').hide();
  });
}


/* lwRTE editor loading */
function loadRTEEditor(iframe_css_class, host) {
  url = 'http://' + host + '/stylesheets/';
	$(iframe_css_class).rte({
    css: ['jquery.rte.css'],
    base_url: url,
    frame_class: 'wysiwyg',
    controls_rte: rte_toolbar,
    controls_html: html_toolbar
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
    $(tags_id).val(question_tags.join(','));
  });
  element.append(deleteButton);
  return element;
}

/* load the previously existing tags */
function loadAddTagButtons() {
	tags_to_load = $('#question_tags').val().trim().split(',');
	while (tags_to_load.length > 0) {
		tag = tags_to_load.shift().trim();
		if (tag.localeCompare(' ') > 0) {
			element = createTagButton(tag, "#question_tags");
			$('#question_tags_values').append(element);
		}
	}
}


/* add new tags to be added to statement */
function bindAddTagButtonEvents() {
  $('#tag_topic_id').keypress(function(event) {
		if (event && event.keyCode == 13) { /* check if enter was pressed */
		  if ($('#tag_topic_id').val().length != 0) {
	      $('.addTag').click();
	    }
			return false;
	  }
	})

	$('.addTag').click(function() {
		entered_tags = $('#tag_topic_id').val().trim().split(",");
		if (entered_tags.length != 0) {
			/* Trimming all tags */
      entered_tags = jQuery.map(entered_tags, function(tag) {
        return (tag.trim());
      });
      existing_tags = $('#question_tags').val().trim();
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
			question_tags = $('#question_tags').val();
      if (new_tags.length > 0) {
        question_tags = ((question_tags.trim().length > 0) ? question_tags + ',' : '') + new_tags.join(',');
        $('#question_tags').val(question_tags);
      }
			$('#tag_topic_id').val('');
			$('#tag_topic_id').focus();
		}
	})
}

/* Remove all activeMenu classes and give it to the static menu item specified
 * through the given parameter. */
function changeMenuImage(item) {
  $('#staticMenu .menuImage').removeClass('activeMenu');
  $('#staticMenu #'+item+' .menuImage').toggleClass('activeMenu');
  $('#static_menu a').removeClass('active');
  $('#static_menu #'+item+'_button').toggleClass('active');
}

/* Use this parameters to render toggle effects.
 * Checks if browser uses opacity. */
var toggleParams;
if (jQuery.support.opacity) {
  toggleParams = {
    'height' : 'toggle',
    'opacity': 'toggle'
  };
} else {
  toggleParams = {
    'height' : 'toggle'
  };
}

/* Lightweight tooltip plugin initialization to create fancy tooltips
 * all over our site.
 * Options and documentation:
 *   http://bassistance.de/jquery-plugins/jquery-plugin-tooltip */
function makeTooltips() {
  $(".ttLink[title]").tooltip({
    track:  true,
    showURL: false
  });
}


/* Add rounded corners to all div elements with class "rounded-box" */
function roundCorners() {
  var str = '<b class="lr l"></b><b class="lr r"></b><b class="tb t"></b><b class="tb b"></b><b class="cn tl"></b><b class="cn tr"></b><b class="cn bl"></b><b class="cn br"></b>';
  $('.rounded-box').append(str);
}

var timer = null;
function showMessageBox(id,permission) {
  if (permission) {
    if (timer != null) {
      clearTimeout (timer);
      $(id).stop(true).hide;
    }
    timer = setTimeout(function(){
      $(id).animate(toggleParams, 500);
    }, 1500);
  }
}

/* Show error or info messages in messagesContainer and hide it with delay. */
function info(text) {
  $('#infoBox').stop().hide();
  $('#errorBox').stop().hide();
  $('#messageContainer #infoBox .message').html(text);
  $('#messageContainer #infoBox').slideDown().animate({opacity: 1.0}, 5000 + text.length*50).slideUp();
}

function error(text) {
  $('#infoBox').stop().hide();
  $('#errorBox').stop().hide();
  $('#messageContainer #errorBox .message').html(text);
  $('#messageContainer #errorBox').slideDown().animate({opacity: 1.0}, 5000 + text.length*50).slideUp();
}

/* Collects all echo_indicators by class and invokes the progressbar-init on them by taking
 * the value from the alt-attribute. */
function makeRatiobars() {
  $.each( $('.echo_indicator'), function() {
    $(this).progressbar({ value: $(this).attr('alt') });
  });
}
