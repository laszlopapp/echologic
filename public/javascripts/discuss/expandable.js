(function($, window, undefined){

  $.fn.expandable = function(settings) {

    function Expandable(exp) {

      var expandable;

      initialise();

      function initialise() {
        expandable = exp;
				var content = expandable.attr('data-content');
        if (!content) {
          return;
        }
        expandable.removeAttr('data-content');

        var path = expandable.attr('href');
        expandable.removeAttr('href');
				
        /* Special ajax event for the statement (collapse/expand)*/
        expandable.bind("click", function(){
					var parent = expandable.parents('div:first');
					var to_show = parent.children(content);
          var supporters_label = expandable.find('.supporters_label');
          if (to_show.length > 0) {
            /* Content is already loaded */
            expandable.toggleClass('active');
						if (settings['animate']) {
							to_show.animate(toggleParams, settings['animation_speed']);
						} else {
							to_show.toggle();
						}
            if (supporters_label) {
							if (settings['animate']) {
						  	supporters_label.animate(toggleParams, settings['animation_speed']);
						  } else {
								supporters_label.toggle();
							}
            }
          } else {
						var loading = $('<span/>').addClass('loading');
						loading.insertAfter(expandable);
            /* Load content */
            $.ajax({
              url:      path,
              type:     'get',
              dataType: 'script',
              success: function(){
								loading.remove();
                expandable.addClass('active');
                if (supporters_label) {
		              if (settings['animate']) {
		                supporters_label.animate(toggleParams, settings['animation_speed']);
		              } else {
		                supporters_label.toggle();
		              }
		            }
              },
							error: function(){loading.remove();}
            })
          }
          return false;
        });
			}
			
			// Auxiliary functions
      
			
			// Public API
      $.extend(this,
      {
        reinitialise: function()
        { 
          initialise();
        }
      });
    };


    $.fn.expandable.defaults = {
      'animation_speed': 300, 
			'animate': true
    };

    // Pluginifying code...
    settings = $.extend({}, $.fn.expandable.defaults, settings);

    var expandableApi = this.data('expandableApi');
    if (expandableApi) {
			expandableApi.reinitialise();
    } else {
      expandableApi = new Expandable(this);
      this.data('expandableApi', expandableApi);
    }
    return this;


  };

})(jQuery,this);
