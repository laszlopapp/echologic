(function($) {

  $.fn.remoteSigninup = function(currentSettings) {

    $.fn.remoteSigninup.defaults = {
      'animation_speed': 250
    };

    // Merging current settings with defaults
    var settings = $.extend({}, $.fn.remoteSigninup.defaults, currentSettings);

    return this.each(function() {
			// Creating and binding the signinup API
			var elem = $(this);
      var signinupApi = elem.data('signinupApi');
	    if (!signinupApi) {
				signinupApi = new RemoteSigninup(elem);
	      elem.data('signinupApi', signinupApi);
	    }
		});


    /*******************************/
    /* The remote signinup handler */
    /*******************************/

    function RemoteSigninup(signinup) {

      var providersPanel = signinup.find('.remote_providers');
      var inputPanel = signinup.find('.remote_input_panel');
      var providerInput = inputPanel.find('.provider_input');
      var progressIndicator = signinup.find('.progress_indicator');

      var tokenUrl;
      var providers;

      // Initialize the signinup panel
      initialize();

      /*
       * Initializes the signinup panel.
       */
      function initialize() {

        // Getting the token URL
        tokenUrl = signinup.data('token-url');
        signinup.removeAttr('data-token-url');

        // Initializing all providers
        providers = signinup.find('.provider').each(function() {
          var provider = $(this);
          provider.data('providerName', provider.data('provider-name'));
          provider.data('providerUrl', provider.data('provider-url'));
          provider.data('requiresInput', provider.data('requires-input'));
          provider.removeAttr('data-provider-name').removeAttr('data-provider-url').removeAttr('data-requires-input');

          provider.click(function() {
            if (!provider.data('requiresInput')) {
              callProvider(provider, null);
            } else {
              promptForInput(provider);
            }
          });
        });

        // Input panel
        inputPanel.find('.back_button').click(function() {
          chooseProvider();
        });
        inputPanel.find('.signinup_button').click(function() {
          var input = providerInput.val();
          if (input.length() > 0) {
            callProvider(providersPanel.find('.provider.' + inputPanel.data('provider')), input);
          }
        });

      }

      /*
       * Calls the provider's URL with the token URL to return to.
       * The 'input', if defined, also gets substituted into the URL.
       */
      function callProvider(provider, input) {
        var finalUrl = provider.data('providerUrl').replace("{url}", tokenUrl);
        if (input) {
          finalUrl = finalUrl.replace("{input}", input)
        }
        progressIndicator.show();
        popup(finalUrl, function() {
          progressIndicator.hide();
        });
      }


      /*
       * Switches to the input panel to get the additional info from the user.
       */
      function promptForInput(provider) {
        if (inputPanel.data('provider')) {
          inputPanel.removeClass(inputPanel.data('provider'));
        }
        var providerName = provider.data('providerName');
        inputPanel.data('provider', providerName).addClass(providerName);

        providersPanel.fadeOut(settings['animation_speed']);
        inputPanel.fadeIn(settings['animation_speed']);
        inputPanel.find('.provider_input').focus();
      }


      /*
       * Switches to the providers panel to let the user choose a different provider.
       */
      function chooseProvider() {
        inputPanel.fadeOut(settings['animation_speed']);
        providersPanel.fadeIn(settings['animation_speed']);
      }

	  }

  };

})(jQuery);


