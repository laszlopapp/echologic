/**
 * @author Tiago
 */

 
(function($) {

  $.fn.statement_search = function(current_settings) {

    $.fn.statement_search.defaults = {
      'animation_speed': 300,
			'per_page' : 7
    };

    // Merging settings with defaults
    var settings = $.extend({}, $.fn.statement_search.defaults, current_settings);

    return this.each(function() {
      // Creating and binding the statement API
      var elem = $(this), statementSearchApi = elem.data('searchApi');
      if (statementSearchApi) {
        statementSearchApi.reinitialise(current_settings);
      } else {
        statementSearchApi = new StatementSearch(elem);
        elem.data('searchApi', statementSearchApi);
      }
    });


    /*************************/
    /* The statement handler */
    /*************************/

    function StatementSearch(search_container) {
			var elements_list = search_container.find('ul');
			var pagination = search_container.find('.more_pagination');
      // Initialize the statement
      initialise();


      // Initializes the statement.
      function initialise() {
        initRatioBars(search_container);
				initMoreButton();
				initScrollPane();
      }
			
			function initRatioBars(container) {
        container.find('.echo_indicator').each(function() {
          var indicator = $(this);
          var echo_value = parseInt(indicator.attr('alt'));
          indicator.progressbar({ value: echo_value });
        });
      }
			
			/*
       * Handles the click on the more Button event (replaces it with an element of class 'more_loading')
       */
      function initMoreButton() {
				var elements_count = search_container.find('li.question').length;
        search_container.find(".more_pagination a:Event(!click)").addClass('ajax').bind("click", function() {
          var moreButton = $(this);
          moreButton.replaceWith($('<span/>').text(moreButton.text()).addClass('more_loading'));
					$.setFragment({"page_count" : elements_count / settings['per_page'] + 1, "page" : ""});
        });
      }
			
			function initScrollPane() {
				elements_list.jScrollPane({animateScroll: true});
			}

      // Public API of statement
      $.extend(this,
      {
        reinitialise: function(resettings)
        {
          settings = $.extend({}, resettings);
          initialise();
        }, 
				insertContent: function(content, pagination_buttons, page)
				{
					var scrollpane = elements_list.data('jsp');
					children_list = scrollpane.getContentPane();
					if (page == 1) {
				  	children_list.find('li').remove();
				  }
					children_list.append(content);
					if (pagination.length > 0) {
				  	pagination.replaceWith(pagination_buttons);
				  } else {
						pagination_buttons.insertAfter(elements_list);
					}
					pagination = pagination_buttons;
					
					scrollpane.reinitialise();
          scrollpane.scrollToBottom();
					initRatioBars(children_list);
					initMoreButton();
				}
      });
    }

  };

})(jQuery);


