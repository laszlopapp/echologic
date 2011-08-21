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
					var targetStack = statement.data('api').getStatementsStack(this, false);
					
					// BIDS
					// logic: parent key will be the alternatives breadcrumb, so return the bids til the previous bid
					var currentBids = $('#breadcrumbs').data('breadcrumbApi').getBreadcrumbStack(null);
					var parentKey = statement.data('api').getParentKey();
					var parentIndex = $.inArray(parentKey, currentBids);
					var targetBids = currentBids.splice(0, parentIndex);

					// save element after which the breadcrumbs will be deleted while processing the response
          $('#breadcrumbs').data('element_clicked', targetBids[targetBids.length-1]);
					// ORIGIN
					origin = $.fragment().origin;
					// AL
          var al = statement.data('api').getTargetAls(false);
					$.setFragment({
				  	"sids": targetStack.join(','),
				  	"nl": true,
				  	"bids": targetBids.join(','),
				  	"origin": origin,
						"al": al.join(',')
				  });
					
					var path = $.queryString(statement.data('api').getStatementUrl(), {
						"current_stack" : targetStack.join(','), 
						"nl" : true, 
						"al" : al.join(',')
					});
          $.getScript(path);
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
