(function($) {

  $.fn.remoteSigninup = function() {

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
              callProvider(provider);
            } else {
              promptForInput(provider);
            }
          });
        });

        // Input panel
        inputPanel.find('.back_button').click(function() {
          chooseProvider();
        });
      }

      /*
       * Calls the provider's URL with the token URL to return to.
       */
      function callProvider(provider) {
        var finalUrl = provider.data('providerUrl').replace("{url}", tokenUrl);
        popup(finalUrl, true);
      }


      /*
       * Switches to the input panel to get the additional info from the user.
       */
      function promptForInput(provider) {
        if (inputPanel.data('provider')) {
          inputPanel.removeClass(inputPanel.data('provider'));
        }
        inputPanel.addClass(provider.data('providerName'));

        providersPanel.fadeOut(250);
        inputPanel.fadeIn(250);
        inputPanel.find('.provider_input').focus();
      }


      /*
       * Switches to the providers panel to let the user choose a different provider.
       */
      function chooseProvider() {
        inputPanel.fadeOut(250);
        providersPanel.fadeIn(250);
      }

	  }

  };

})(jQuery);


