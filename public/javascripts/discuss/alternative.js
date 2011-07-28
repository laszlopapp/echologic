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
			// statement has alternatives
      var alternatives = statement.find('.alternatives');
			var teaser = alternatives.find('.teaser');
			
			// statement is an alternative
			var closeButton = statement.find('.alternative_close');
			
      initialize();

      /*
       * Initializes an echoable statement in a form or in normal mode.
       */
      function initialize() {
				// statement has alternatives
        //initPanel();
				
				// statement is an alternative
				initCloseButton();
      }

			function initPanel() {
				alternatives.bind('mouseover', function(){
					panelHighlight();
				});
        alternatives.bind('mouseleave', function(){
					panelNormal();
        });
			}
			
			function initCloseButton() {
				closeButton.bind('click', function(){
					// SIDS
					var targetStack = statement.data('api').getStatementsStack(this, false);
					
					// BIDS
					var hubChild = targetStack[targetStack.length-1];
					var bids = $('#breadcrumbs').data('breadcrumbApi').getBreadcrumbStack(null);
					var bidsStatementIds = $.map(bids, function(a){return a.replace(/[^0-9]+/, '');});
          var level = $.inArray(hubChild, bidsStatementIds); 
          bids = bids.splice(0, level);
          
					$('#breadcrumbs').data('element_clicked', bids[bids.length-1]);
					
					// ORIGIN
					origin = $.fragment().origin;
										
					$.setFragment({
				  	"sids": targetStack.join(','),
				  	"nl": true,
				  	"bids": bids.join(','),
				  	"origin": origin,
				  	"hub": ''
				  });
					return false;
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
					//panelHighlight();
					teaser.fadeIn(120);
				},
				normal_mode: function() {
					//panelNormal();
					teaser.fadeOut(120);
				}
      });
    }

  };

})(jQuery);
