// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

  /* Do init stuff. */
  $(function() {

    $.fragmentChange(true);
    positionMainMenuDropdowns();
    makeTooltips();
    roundCorners();
    bindLanguageSelectionEvents();
    moreHideButtonEvents();
    staticMenuClickEvents();
    ajaxClickEvents();
    loadTabsContainer();
    loadAjaxForms();
    uploadFormSubmit();
    loadAboutUs();
		initSigninupButtons();

    /* Always send the authenticity_token with Ajax */
    $(document).ajaxSend(function(event, request, settings) {
      if ( settings.type == 'post' ) {
        settings.data = (settings.data ? settings.data + "&" : "")
        + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
      }
    });

    $('#user_session_email').focus();
    $('.autogrow').autogrow();
  });


  /* TODO optimize splitting of url! */
  /* TODO action set checking */
  /* Sets the fragment to the controller and action of the anchors href attribute. */
  function setActionControllerFragment(href) {
    var controller = href.toString().split('/')[4];
    var action = href.toString().split('/')[5];
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

  function positionMainMenuDropdowns() {
    $('li.main_menu_item').each(function () {
      var menuItem = $(this);
      menuItem.find('.dropdown').css('left', (menuItem.innerWidth()-150)/2 - 7);
    });
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
  function roundCorners() {
    var str = '<b class="lr l"></b><b class="lr r"></b><b class="tb t"></b><b class="tb b"></b><b class="cn tl"></b><b class="cn tr"></b><b class="cn bl"></b><b class="cn br"></b>';
    $('.rounded-box').livequery(function() {
      $(this).append(str);
    });
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



  function loadTabsContainer() {
    $('.tab_details_container').livequery(function() {
     $(this).tabs();
    });
  }

  /* loads form ajaxs */
  function loadAjaxForms() {
    $('form.ajax_form').livequery(function () {
      $(this).ajaxForm({ dataType : 'script' });
    });
  }

  /* TODO: Load the upload picture forms here */
  function uploadFormSubmit(){
    $('#dialog_container .upload_form').livequery(function(){
      var element = $(this);
      element.submit(function(){
				$(this).ajaxSubmit({
          beforeSend: function(){
						$('#uploading_progress').show();
          },
          complete: function(){
						$('#uploading_progress').hide();
          },
          success: function(data, status) {
				    $.ajax({
              type: 'get',
              dataType: 'script',
              url: element.data('image-redirect')
            });
            $('#dialog_container').dialog('close');
          }
        });
        return false;
      });
    })
  }

  function loadAboutUs() {
    $('#about_container').livequery(function(){
      $('#about_team_link').click(function() {
        $('#about_container').tabs('select', 1);
        return false;
      });
      $(this).bind('tabsshow', function(event, ui) {
        if (ui.panel.id == "team") {
          $('#team_members').jScrollPane({animateTo: true, wheelSpeed: 25});
        }
				if (ui.panel.id == "partners") {
          $('#partner_orgas').jScrollPane({animateTo: true, wheelSpeed: 25});
        }
      });
    });
  }


  /* REDIRECTION AFTER SESSION EXPIRE */
  function redirectToUrl(controller, url) {
    switch(controller) {
      case 'statements': redirectToStatementUrl();
      break;
      default: window.location.replace(url);
    }
  }

  function initSigninupButtons() {
		$('.signinup_container .signinup_switch').live('click', function() {
			var to_show = $(this).attr('href');
			$(to_show).show();
			$(this).parents('.signinup_container').hide();
			return false;
		});
	}


  /* Handling pop-ups and redirections in parent window. */
  function popup(mylink, windowname) {
    if (!window.focus) {
      return true;
    }
    var href;
    if (typeof(mylink) == 'string') {
      href = mylink;
    }
    else {
      href = mylink.href;
    }
    window.open(href, windowname, 'width=800,height=450,scrollbars=yes');
    return false;
  }

  function targetopener(mylink, closeme, closeonly) {
    if (!(window.focus && window.opener)) {
      return true;
    }
    window.opener.focus();
    if (!closeonly) {
      if (typeof(mylink) == 'string') {
        window.opener.location.href = mylink;
      } else {
        window.opener.location.href = mylink.href;
      }
    }
    if (closeme) {
      window.close();
    }
    return false;
  }

  /* Handling modal overlays */
  function openModalDialog(content) {
    $('#dialog_container').empty().append('<div/>').find('div').attr('id', 'modal_dialog').html(content);

    $('#modal_dialog').overlay({
      closeOnClick: false,
      mask: {
        color: '#B5C0C9',
        loadSpeed: 300,
        opacity: 0.85
      },
      load: true,
      left: 'center',
      top: 'center',
      speed: 700,
      onClose: function (event) {
        $('#modal_dialog').remove();
      }
    });
  }

  /*
   * Detecting mobile devices.
   */
	function isMobileDevice() {
    var userAgent = navigator.userAgent.toLowerCase();
		return userAgent.match(/android/i) ||
           userAgent.match(/iphone/i)  ||
           userAgent.match(/ipod/i) ||
           userAgent.match(/ipad/i) ||
           userAgent.match(/webos/i) ||
           userAgent.match(/palm/i) ||
           userAgent.match(/blackberry/i) ||
           userAgent.match(/windows ce/i);
	}