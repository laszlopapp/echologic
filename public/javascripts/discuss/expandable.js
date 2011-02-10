(function($) {

  $.fn.expandable = function(current_settings) {

     $.fn.expandable.defaults = {
			'animate': true,
			'animation_params' : {
        'height' : 'toggle',
        'opacity': 'toggle'
      },
      'animation_speed': 300,
			'loading_class': '.loading'
    };

    // Merging settings with defaults
    var settings = $.extend({}, $.fn.expandable.defaults, current_settings);

    return this.each(function() {

	    // Creating expandable and binding its API
	    var elem = $(this);
      var expandableApi = elem.data('expandableApi');
	    if (expandableApi) {
				expandableApi.reinitialise();
	    } else {
	      expandableApi = new Expandable(elem);
	      elem.data('expandableApi', expandableApi);
	    }
		});


    /* The expandable handler */
    function Expandable(expandable) {
      initialise();

      function initialise() {

        var path = expandable.attr('href');
        expandable.removeAttr('href');

			  // Collapse/expand clicks
        expandable.bind("click", function(){
					var parent = expandable.parents('div:first');
					var to_show = parent.children('.expandable_content');
          var supporters_label = expandable.find('.supporters_label');
          if (to_show.length > 0) {
            // Content is already loaded
            expandable.toggleClass('active');
						if (settings['animate']) {
							to_show.animate(settings['animation_params'],
                              settings['animation_speed']);
						} else {
							to_show.toggle();
						}
            if (supporters_label) {
							if (settings['animate']) {
						  	supporters_label.animate(settings['animation_params'],
                                         settings['animation_speed']);
						  } else {
								supporters_label.toggle();
							}
            }
          } else {
            // Load content now
						var loading = expandable.parent().find(settings['loading_class']);
						if (loading.length > 0) {
							loading.show();
						}
						else {
							loading = $('<span/>').addClass('loading');
							loading.insertAfter(expandable);
						}
            $.ajax({
              url:      path,
              type:     'get',
              dataType: 'script',
              success:  function() {
								loading.hide();
								if (parent.children('.expandable_content').length > 0) {
									expandable.addClass('active');
								}
                if (supporters_label) {
		              if (settings['animate']) {
		                supporters_label.animate(settings['animation_params'],
                                             settings['animation_speed']);
		              } else {
		                supporters_label.toggle();
		              }
		            }
              },
							error: function(){loading.hide();}
            })
          }
          return false;
        });
			}

			// Public API
      $.extend(this,
      {
        reinitialise: function()
        {
          initialise();
        }
      });
    }

  };

})(jQuery);
