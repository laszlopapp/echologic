(function($) {

  $.fn.expandable = function(current_settings) {

     $.fn.expandable.defaults = {
			'animate': true,
			'animation_params' : {
        'height' : 'toggle',
        'opacity': 'toggle'
      },
      'animation_speed': 300,
			'loading_class': '.loading',
			
			// SPECIAL CONDITION ELEMENTS
			'condition_element': null,
      'condition_class': ''
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
			var expandable_parent = expandable.parents('div:first');
			var expandable_supporters_label = expandable.find('.supporters_label');
			var expandable_loading = expandable.parent().find(settings['loading_class']);
			var expandable_content = expandable_parent.children('.expandable_content');
			
			var path = expandable.attr('href');
			expandable.removeAttr('href');
			
      initialise();

      function initialise() {
			  // Collapse/expand clicks
        expandable.bind("click", function(){
					if (!settings['condition_element']) {
						toggleExpandable();
					} else if(settings['condition_element'].hasClass(settings['condition_class'])) {
						if(settings['condition_element'].hasClass('pending')) {
							expandable.addClass('clicked');
						} else {
							toggleExpandable();
						}
					}
          return false;
        });
			}
			
			function toggleExpandable () {
        if (expandable_content.length > 0) {
          // Content is already loaded
          expandable.toggleClass('active');
          if (settings['animate']) {
            expandable_content.animate(settings['animation_params'], settings['animation_speed']);
          }
          else {
            expandable_content.toggle();
          }
          if (expandable_supporters_label) {
            if (settings['animate']) {
              expandable_supporters_label.animate(settings['animation_params'], settings['animation_speed']);
            }
            else {
              expandable_supporters_label.toggle();
            }
          }
        }
        else {
          // Load content now
          if (expandable_loading.length > 0) {
            expandable_loading.show();
          }
          else {
            expandable_loading = $('<span/>').addClass('loading');
            expandable_loading.insertAfter(expandable);
          }
          $.ajax({
            url: path,
            type: 'get',
            dataType: 'script',
            success: function(){
              expandable_loading.hide();
							expandable_content = expandable_parent.children('.expandable_content');
              if (expandable_content.length > 0) {
                expandable.addClass('active');
              }
              if (expandable_supporters_label) {
                if (settings['animate']) {
                  expandable_supporters_label.animate(settings['animation_params'], settings['animation_speed']);
                }
                else {
                  expandable_supporters_label.toggle();
                }
              }
            },
            error: function(){
              expandable_loading.hide();
            }
          })
        }
			}

			// Public API
      $.extend(this,
      {
        reinitialise: function()
        {
          initialise();
        },
				toggle: function()
				{
					toggleExpandable();
				}
      });
    }

  };

})(jQuery);
