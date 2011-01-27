(function($){

  $.fn.echoable = function() {

    /* Creating echoable and binding its API */
    var echoableApi = this.data('echoableApi');
    if (echoableApi) {
      echoableApi.reinitialize();
    } else {
      echoableApi = new Echoable(this);
      this.data('echoableApi', echoableApi);
    }
    return this;


    /****************/
    /* The echoable */
    /****************/

	  function Echoable(echoable) {
      var echo_button, echo_label;
      initialize();

			/*
       * Initializes an echoable statement in a form or in normal mode.
       */
			function initialize() {
        echo_button = echoable.find('.action_bar .echo_button');
        if (echo_button.length == 0) {
          return;
        }
        echo_label = echo_button.find('.label');

				if (echoable.hasClass('new')) {
					initNewStatementEchoButton();
				} else {
					initEchoButton();
				}
		  }

      function initLabelMessages() {
        var messages = {
          'supported'     : echo_label.attr('data-supported'),
          'not_supported' : echo_label.attr('data-not-supported')
        };
        echo_label.data('messages', messages);
        echo_label.removeAttr('data-supported').removeAttr('data-not-supported');
        var state = echo_button.hasClass('supported') ? 'supported' : 'not_supported';
        echo_label.text(echo_label.data('messages')[state]);
			}


      /****************************/
      /* Forms for new statements */
      /****************************/

			// Auxiliary Functions
      function initNewStatementEchoButton() {
        initLabelMessages();
				echo_button.bind('click', function(){
					var button = $(this).find('.echo_button_icon');
					var label = $(this).find('.label');
          if ($(this).hasClass('not_supported')) {
            supportEchoButton();
						label.text(label.data('messages')['supported']);
          } else if ($(this).hasClass('supported')) {
            unsupportEchoButton();
						label.text(label.data('messages')['not_supported']);
          }
        });
			}

      /*
       * Triggers all the visual events associated with a support from an echo statement
       */
      function supportEchoButton() {
				var form = echo_button.parents('form.statement');
				updateEchoButton('supported', 'not_supported');
				info(echo_button.data('messages')['supported']);
        echoable.find('#echo').val(true);
        updateSupportersNumber(form,'1');
        updateSupportersBar(form, 'echo_indicator', 'no_echo_indicator', '10');
      }

			/*
       * Triggers all the visual events associated with an unsupport from an echo statement
       */
      function unsupportEchoButton() {
				var form = echo_button.parents('form.statement');
				updateEchoButton('not_supported', 'supported');
				info(echo_button.data('messages')['not_supported']);
        echoable.find('#echo').val(false);
        updateSupportersNumber(form,'0');
        updateSupportersBar(form, 'no_echo_indicator', 'echo_indicator', '0');
      }

      function updateSupportersNumber(form, value) {
        var supporters_label = form.find('.supporters_label');
        var supporters_text = supporters_label.text();
        supporters_label.text(supporters_text.replace(/[0-9]/, value));
      }

      function updateSupportersBar(form, classToAdd, classToRemove, ratio) {
        var old_supporter_bar = form.find('.supporters_bar');
        var new_supporter_bar = $('<span></span>').attr('class', old_supporter_bar.attr('class')).
                                addClass(classToAdd).removeClass(classToRemove).attr('alt', ratio);
        new_supporter_bar.attr('title', form.find('.supporters_label').text());
        old_supporter_bar.replaceWith(new_supporter_bar);
      }


      /************************************/
      /* For normal statements (not form) */
      /************************************/

      function initEchoButton() {
        initLabelMessages();
				echo_button.bind('click', function() {

          // Abandon or proceed
					if(echo_button.hasClass('pending') || echo_button.hasClass('clicked')) {
						return false;
					} else {
						echo_button.addClass('clicked').addClass('pending');
					}

          // Icon
          var to_remove, to_add;
					if (echo_button.hasClass('supported')) {
					  to_remove = 'supported';
            to_add = 'not_supported';
					} else {
            to_remove = 'not_supported';
            to_add = 'supported';
					}

          /* pre-request */
					updateEchoButton(to_add, to_remove);
					echo_label.text(echo_label.data('messages')[to_add]);

					var href = echo_button.attr('href');

					$.ajax({
			      url:      echo_button.attr('href'),
			      type:     'post',
			      dataType: 'script',
			      data:   { '_method': 'put' },
						success: function(data, textStatus, XMLHttpRequest) {
              echo_button.removeClass('pending');
              // Request returns with successful with an info, but the echo itself failed
              if(href == echo_button.attr('href')) {
							  rollback(to_remove, to_add);
							}
						},

						error: function() {
							echo_button.removeClass('pending');
							rollback(to_remove, to_add);
						}
			    });

          function rollback(to_remove, to_add) {
            updateEchoButton(to_remove, to_add);
					  echo_label.text(echo_label.data('messages')[to_remove]);
            var error_lamp = echo_button.find('.error_lamp');
            error_lamp.css('opacity','0.70').show().fadeTo(1000, 0, function() {
              error_lamp.hide();
            });
          }

					return false;
        });

        // Removing the clicked class
        echo_button.bind('mouseleave', function() {
					echo_button.removeClass('clicked');
				});
			}

			function updateEchoButton(classToAdd, classToRemove) {
        echo_button.removeClass(classToRemove).addClass(classToAdd);
      }


			// Public API
      $.extend(this,
      {
				reinitialize: function() {
          initialize();
        },
				updateState: function(href, supporters_bar, supporters_number) {
          echo_button.attr('href', href);
          echoable.find('.header .supporters_bar').replaceWith(supporters_bar);
          echoable.find('.header .supporters_label').text(supporters_number);
          return this;
        },
				loadEchoLabelMessages: function(messages) {
          echo_label.data('messages', messages);
          return this;
        },
				loadEchoInfoMessages: function(messages) {
          echo_button.data('messages', messages);
          return this;
        }
			});
		}

  };

})(jQuery);
