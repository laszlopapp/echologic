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
			var action_bar = $('#action_bar');
      // Initialize the statement
      initialise();


      // Initializes the statement.
      function initialise() {
        initEchoIndicators(search_container);
				initMoreButton();
				//initScrollPane();
      }

			function initEchoIndicators(container) {
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
					var loadingMoreButton = $('<span/>').text(moreButton.text()).addClass('more_loading');
					var page_count = elements_count / settings['per_page'] + 1;
          moreButton.replaceWith(loadingMoreButton);
					$.setFragment({"page_count" : page_count, "page" : ""});
					$.ajax({
						url: moreButton.attr('href'),
            type: 'get',
            dataType: 'script',
            success: function(){
							search_container.find('a').each(function(){
								updateUrlCount($(this), page_count);
							});
			      },
						error: function(){
							loadingButton.replaceWith(moreButton);
			      }
					});
					return false;
        });
      }

			function updateUrlCount(element, page_count) {
				element.attr('href',decodeURI(element.attr('href')).replace(/\|\d+/g, "|" + page_count));
			}

//			function initScrollPane() {
//				elements_list.jScrollPane({animateScroll: true});
//			}

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
					var children_list = $("#questions_container .content ul");
					if (page == 1) {
				  	children_list.children().remove();
				  }
					children_list.append(content);

          // Scrolling to the first new list element
          if (page > 1) {
            var first_new_id = "#" + $(content).first().attr("id");
            $.scrollTo(first_new_id, 700);
          }

					if (pagination.length > 0) {
				  	pagination.replaceWith(pagination_buttons);
				  } else {
						pagination_buttons.insertAfter(elements_list);
					}
					pagination = pagination_buttons;

					initEchoIndicators(children_list);
					initMoreButton();
				}
      });
    }

  };

})(jQuery);


