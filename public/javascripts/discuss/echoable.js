(function($, window, undefined){

  $.fn.echoable = function(settings){

	  function Echoable(elem, s){
		  var jsp = this;

      initialise(s);


			/*
       * Initializes echo button click handling on new statement forms
       */
			function initialise(s){
				if (elem.hasClass('new')) {
					initNewStatementEchoButton(elem);
				} else {
					initEchoButton(elem);
				}
				
		  }

			// Auxiliary Functions
      function initNewStatementEchoButton(element) {
				initLabelMessages(element);
				element.find('#echo_button .new_record').bind('click', function(){
					var label = $(this).next();
          if ($(this).hasClass('not_supported')) {
            supportEchoButton($(this));
						label.text(label.data('messages')['not_supported']);
          } else if ($(this).hasClass('supported')) {
            unsupportEchoButton($(this));
						label.text(label.data('messages')['supported']);
          }
        });
			}

      function initEchoButton(element) {
				initLabelMessages(element);
				
				
				
				element.find('#echo_button').bind('click', function(){
					if($(this).hasClass('locked')) {
						return false;
					} else {
						$(this).addClass('locked');
					}
					var button = $(this).find('span.echo_icon');
					var label = button.next();
					if (button.hasClass('supported')) {
						var to_remove = 'supported', to_add = 'not_supported';
					} else {
            var to_remove = 'not_supported', to_add = 'supported';
					}
					/* update image */
					updateEchoButton(button, to_add, to_remove);
					label.text(label.data('messages')[to_remove]);
					$.ajax({
			      url:      this.href,
			      type:     'post',
			      dataType: 'script',
			      data:   { '_method': 'put' },
						success: function() {
							$(this).removeClass('locked');
						},
						error: function() {
							$(this).removeClass('locked');
							updateEchoButton(button, to_remove, to_add);
							label.text(label.data('messages')[to_add]);
						}
			    });
					return false;
        });
			}
			
			function initLabelMessages(element){
				var desc = element.find('span.label');
        var messages = {'supported' : desc.attr('data-supported'), 'not_supported' : desc.attr('data-not-supported')};
        desc.data('messages', messages);
        desc.removeAttr('data-supported');desc.removeAttr('data-not-supported');
        var type = desc.prev().hasClass('supported') ? 'not_supported' : 'supported'
        desc.text(desc.data('messages')[type]);
			}

			/*
       * triggers all the visual events associated with a support from an echo statement
       */
      function supportEchoButton(button) {
				var form = button.parents('form.statement');
				updateEchoButton(button, 'supported', 'not_supported');
				info(form.find('.action_bar').data('messages')['supported']);
        elem.find('#echo').val(true);
        updateSupportersNumber(form,'1');
        updateSupportersBar(form, 'echo_indicator', 'no_echo_indicator', '10');
      }

			/*
       * triggers all the visual events associated with an unsupport from an echo statement
       */
      function unsupportEchoButton(button) {
				var form = button.parents('form.statement');
				updateEchoButton(button, 'not_supported', 'supported');
				info(form.find('.action_bar').data('messages')['not_supported']);
        elem.find('#echo').val(false);
        updateSupportersNumber(form,'0');
        updateSupportersBar(form, 'no_echo_indicator', 'echo_indicator', '0');
      }

			function updateEchoButton(button, classToAdd, classToRemove) {
        button.removeClass(classToRemove).addClass(classToAdd);
      }

      function updateSupportersNumber(form, value) {
        var supporters_label = form.find('.supporters_label');
        var supporters_text = supporters_label.text();
        supporters_label.text(supporters_text.replace(/[0-9]/, value));
      }

      function updateSupportersBar(form, classToAdd, classToRemove, ratio) {
        var old_supporter_bar = form.find('.supporters_bar');
        var new_supporter_bar = $('<span></span>').attr('class', old_supporter_bar.attr('class')).addClass(classToAdd).removeClass(classToRemove).attr('alt', ratio);
        new_supporter_bar.attr('title', form.find('.supporters_label').text());
        old_supporter_bar.replaceWith(new_supporter_bar);
      }


			// Public API
      $.extend(jsp,
      {
				reinitialise: function(s)
        {
          s = $.extend({}, s, settings);
          initialise(s);
        },
				// API Functions
				updateSupport: function (action_bar, supporters_bar, supporters_label) {
          elem.find('.action_bar').replaceWith(action_bar);
          elem.find('.supporters_bar:first').replaceWith(supporters_bar);
          elem.find('.supporters_label').replaceWith(supporters_label);
          return this;
        },
				loadEchoLabelMessages: function (messages) {
          elem.find('.action_bar .label').data('messages', messages);
          return this;
        },
				loadEchoInfoMessages: function (messages) {
          elem.find('.action_bar').data('messages', messages);
          return this;
        }
			});
		};

		$.fn.echoable.defaults = {
      'animation_speed': 500
    };

	  // Pluginifying code...
    settings = $.extend({}, $.fn.echoable.defaults, settings);

		var ret;

    var elem = $(this), api = elem.data('echoableApi');
    if (api) {
      api.reinitialise(settings);
    } else {
    api = new Echoable(elem, settings);
      elem.data('echoableApi', api);
    }
    ret = ret ? ret.add(elem) : elem;

    return ret;

  };
})(jQuery,this);
