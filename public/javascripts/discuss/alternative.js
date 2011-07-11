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
      var alternatives = statement.find('.alternatives');
			var arrow = alternatives.find('.arrow');
      initialize();

      /*
       * Initializes an echoable statement in a form or in normal mode.
       */
      function initialize() {
        initPanel();
      }

			function initPanel() {
				alternatives.bind('mouseover', function(){
					panelHighlight();
				});
        alternatives.bind('mouseleave', function(){
					panelNormal();
        });
			}

      function panelHighlight() {
				alternatives.find('a.statement_link').animate({color : settings['highlight_color']}, 100);
			}

			function panelNormal() {
        alternatives.find('a.statement_link').animate({color : settings['normal_mode_color']}, 100);
			}


      // Public API
      $.extend(this,
      {
        reinitialize: function() {
          initialize();
        },
				highlight: function() {
					panelHighlight();
					arrow.fadeIn(100);
				},
				normal_mode: function() {
					panelNormal();
					arrow.fadeOut(100);
				}
      });
    }

  };

})(jQuery);
