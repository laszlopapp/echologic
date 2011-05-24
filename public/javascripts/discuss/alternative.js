(function($){

  $.fn.alternative = function() {


    // Merging settings with defaults
    var settings = {
      'highlight_color' : '#21587F',
      'normal_mode_color' : '#888888'
    };

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


    /*******************/
    /* The Alternative */
    /*******************/

    function Alternative(statement) {
      var alternative_panel = statement.find('.alternative_panel');
			var arrow = alternative_panel.find('.arrow');
      initialize();

      /*
       * Initializes an echoable statement in a form or in normal mode.
       */
      function initialize() {
        initPanel();
      }
			
			function initPanel() {
				alternative_panel.bind('mouseover', function(){
					panelHighlight();
				});
        alternative_panel.bind('mouseleave', function(){
					panelNormal();
        });
			}

      function panelHighlight() {
				alternative_panel.find('a.statement_link').animate({color : settings['highlight_color']}, 300);
			}
			
			function panelNormal() {
        alternative_panel.find('a.statement_link').animate({color : settings['normal_mode_color']}, 300);				
			}


      // Public API
      $.extend(this,
      {
        reinitialize: function() {
          initialize();
        },
				highlight: function() {
					panelHighlight();
					arrow.fadeIn(300);
				},
				normal_mode: function() {
					panelNormal();
					arrow.fadeOut(300);
				}
      });
    }

  };

})(jQuery);
