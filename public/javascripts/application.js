// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


/* Do init stuff. */
$(document).ready(function () {
	
	makeRatiobars();
	
  makeTooltips();
	
	roundCorners();

  bindLanguageSelectionEvents();

  moreHideButtonEvents();

  staticMenuClickEvents();

  ajaxClickEvents();

  loadTabsContainer();
	
	loadSearchAjaxForms();
	
	loadFeedbackAjaxForm();
  

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
function ajaxClickEvents() {
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
	
	$(".ajax_display").live("click", function() {
		$(this).toggleClass('active');
		authors = $(this).parents(".statement").find($(this).attr("show"));
		if (authors.length > 0) {authors.animate(toggleParams, 500);}
		else 
		{$.getScript(this.href);}
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
function staticMenuClickEvents() {
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
function moreHideButtonEvents() {
  $('.moreButton').live('click', (function() {
    $(this).next().animate(toggleParams, 300);
    $(this).hide();
    $(this).prev().show();
  }));

  $('.hideButton').live('click', (function() {
    $(this).next().next().animate(toggleParams, 300);
    $(this).hide();
    $(this).next().show();
  }));
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
  $(".ttLink[title]").livequery(function() {
		$(this).tooltip({
	    track:  true,
	    showURL: false
	  });
	});
}

/* Add rounded corners to all div elements with class "rounded-box" */
function roundCorners(){
  var str = '<b class="lr l"></b><b class="lr r"></b><b class="tb t"></b><b class="tb b"></b><b class="cn tl"></b><b class="cn tr"></b><b class="cn bl"></b><b class="cn br"></b>';
  $('.rounded-box').livequery(function(){
		$(this).append(str);
	});
};

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
  $('.echo_indicator').livequery(function() {
    $(this).progressbar({ value: $(this).attr('alt') });
  });
}

function loadTabsContainer() {
	$('.tab_details_container').livequery(function() {
	 $(this).tabs();
	});
}

/* Makes all search forms ajax */
function loadSearchAjaxForms() {
  $('#search_form').livequery(function () {
    $(this).ajaxForm({ dataType : 'script' });
  });
}

/* Makes feedback form ajax */
function loadFeedbackAjaxForm() {
  $('#new_feedback_form').livequery(function () {
    $(this).ajaxForm({ dataType : 'script' });
  });
}