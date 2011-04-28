(function($){

  $.fn.alternative = function() {


    // Merging settings with defaults
    var settings = {
      'highlight_color' : '#BFCFFE',
      'normal_mode_color' : '#D4D3D3'
    }
		
    return this.each(function() {
      /* Creating echoable and binding its API */
      var elem = $(this), alternativeApi = elem.data('alternativeApi');
      if (alternativeApi) {
        alternativeApi.reinitialize();
      } else {
        alternativeApi = new Alternative(elem);
        elem.data('alternativeApi', alternativeApi);
      }
    });


    /****************/
    /* The echoable */
    /****************/

    function Alternative(statement) {
      var alternative_panel = statement.find('.alternative_panel');
			var arrow = alternative_panel.find('.arrow');
      initialize();

      /*
       * Initializes an echoable statement in a form or in normal mode.
       */
      function initialize() {
				
      }



      // Public API
      $.extend(this,
      {
        reinitialize: function() {
          initialize();
        },
				highlight: function() {
					alternative_panel.animate({backgroundColor : settings['highlight_color']}, 300);
					arrow.fadeIn(300);
				},
				normal_mode: function() {
					alternative_panel.animate({backgroundColor : settings['normal_mode_color']}, 300);
					arrow.fadeOut(300);
				}
      });
    }

  };

})(jQuery);
