(function($){

  $.fn.placeholder = function(current_settings) {

    $.fn.placeholder.defaults = {
      "text_class"    : "iframe.rte_doc",
			"changed_class" : "changed",
			"default_attr"  : "data-default",
			"focus_class"   : "has_focus"
    };
		
		// Merging settings with defaults
    var settings = $.extend({}, $.fn.placeholder.defaults, current_settings);

    return this.each(function() {
      var elem = $(this), placeholderApi = elem.data('placeholderApi');
      if (placeholderApi) {
        placeholderApi.reinitialize();
      } else {
        placeholderApi = new Placeholder(elem);
        elem.data('placeholderApi', placeholderApi);
      }
    });


    /****************/
    /* The echoable */
    /****************/

    function Placeholder(container) {
      initialize();

      /*
       * Initializes an echoable statement in a form or in normal mode.
       */
      function initialize() {
				loadInputs();
				loadText();
				loadSubmitClean();
      }
			
			function loadInputs() {
				container.find("input[type='text']").each(function(index){
					var inputText = $(this);
					var initValue = inputText.val();
          var value = inputText.attr(settings["default_attr"]);
          inputText.toggleVal({
            populateFrom: 'custom',
            text: value,
						changedClass: settings["changed_class"],
						focusClass: settings["focus_class"]
          });
          inputText.removeAttr(settings["default_attr"]);
          if (index == 0) {
            inputText.blur();
          }
					if (initValue && initValue.length > 0) {
				  	inputText.val(initValue);
						inputText.focus();
						inputText.blur();
				  }
        });
			}
			
			function loadText() {
				// Text Area (RTE Editor)
        container.find(settings["text_class"]).each(function(){
					var editor = $(this);
	        var value = editor.attr(settings["default_attr"]);
	        var doc = $(editor.contents().get(0));
	        var text = $(doc).find('body');
	        if(text && text.html().length == 0) {
	          var label = $("<span class='defaultText'></span>").html(value);
	          label.insertAfter(editor).click(function() {
	            doc.click();
	          });
	
	          doc.bind('click', function(){
	            label.hide();
	            editor.focus();
	          });
	          doc.bind('blur', function(){
	            var new_text = $(editor.contents().get(0)).find('body');
	            if (new_text.html().length == 0) {
	              label.show();
	            }
	          });
	        }
	        editor.removeAttr(settings["default_attr"]);
				});
			}
			
			function loadSubmitClean() {
				// Clean text inputs on submit
        container.bind('submit', (function() {
					cleanToggleValues($(this));
        }));
			}
			
			function cleanToggleValues(content) {
				content.find(".toggleval").each(function() {
          if($(this).val() == $(this).data("defText")) {
            $(this).val("");
          }
        });
			}


      // Public API
      $.extend(this,
      {
        reinitialize: function() {
          initialize();
        },
				cleanDefaultValues: function () {
					cleanToggleValues(container);
				}
      });
    }
  };

})(jQuery);
