(function($) {

  $.fn.statementForm = function(currentSettings) {

    $.fn.statementForm.defaults = {
      'animation_speed': 500,
      'taggableClass' : 'taggable'
    };

    // Merging settings with defaults
    var settings = $.extend({}, $.fn.statementForm.defaults, currentSettings);

    return this.each(function() {
	    // Creating and binding the statement form API
	    var elem = $(this), statementFormApi = elem.data('statementFormApi');
	    if (statementFormApi) {
	      statementFormApi.reinitialise();
	    } else {
	      statementFormApi = new StatementForm(elem);
	      elem.data('statementFormApi', statementFormApi);
	    }
		});


    /******************************/
    /* The statement form handler */
    /******************************/

    function StatementForm(form) {
			var chosenLanguage = form.find('select.language_combo');

			initialise();

			function initialise() {
				          

				if (!isMobileDevice()) {
					loadRTEEditor();
				}
        // New Statement Form Helpers
        if (form.hasClass('new')) {
          hideNewStatementType();
          loadDefaultText();
          handleStatementFormsSubmit();
          initFormCancelButton();
					initAutoCompleteTitle();
        }

        // Taggable Form Helpers
        if (form.hasClass(settings['taggableClass'])) {
          form.taggable();
        }
			}

      

			/*
       * Loads the Rich Text Editor for the statement text.
       */
      function loadRTEEditor() {
        var textArea = form.find('textarea.rte_doc, textarea.rte_tr_doc');
        var defaultText = textArea.data('default');
        var url = 'http://' + window.location.host + '/stylesheets/';

        textArea.rte({
          css: ['jquery.rte.css'],
          base_url: url,
          frame_class: 'wysiwyg',
          controls_rte: rte_toolbar,
          controls_html: html_toolbar
        });
        form.find('.focus').focus();

        // The default placeholder text
        form.find('iframe').attr('data-default', defaultText);
      }


      /*
       * Shows the statement type on new statement forms
       */
      function showNewStatementType() {
        var input_type = form.find('input#type');
        input_type.attr('value', input_type.data('value'));
      }


			/*
       * Hides the statement type on new statement forms.
       */
      function hideNewStatementType() {
        var input_type = form.find('input#type');
        input_type.data('value', input_type.attr('value'));
        input_type.removeAttr('value');
      }


			/*
       * Loads the form's default texts for title, text and tags.
       */
			function loadDefaultText() {
        if (!form.hasClass('new')) {return;}

        form.placeholder();

      }

      /*
       * Submits the form.
       */
			function handleStatementFormsSubmit() {
        form.bind('submit', (function() {
          showNewStatementType();
          $.ajax({
            url: this.action,
            type: "POST",
            data: $(this).serialize(),
            dataType: 'script',
            success: function(data, status){
              hideNewStatementType();
            }
          });
          return false;
        }));
      }

			/*
       * Handles Cancel Button click on new statement forms.
       */
      function initFormCancelButton() {
        var cancelButton = form.find('.buttons a.cancel');
        if ($.fragment().sids) {
          var sids = $.fragment().sids;
          var new_sids = sids.split(",");
          var path = "/" + new_sids[new_sids.length-1];
          new_sids.pop();

          cancelButton.addClass("ajax");
          cancelButton.attr('href', $.queryString(cancelButton.attr('href').replace(/\/\d+/, path), {
            "sids": new_sids.join(","),
            "bids": '',
						"origin": $.fragment().origin
          }));
        }
      }

      function initAutoCompleteTitle() {
				var title = form.find('.header input');
				var auto_complete_button = form.find('.header .auto_complete');
				auto_complete_button.bind('click', function(){
					var to_add, to_remove;
					if($(this).hasClass('enabled')) {
						to_remove = 'enabled';
						to_add = 'disabled';
					} else if ($(this).hasClass('disabled')) {
						to_remove = 'disabled';
						to_add = 'enabled';
					}
					$(this).addClass(to_add).removeClass(to_remove);
				});
				title.autocompletes('../../statements/auto_complete_for_statement_title',
				                    {
												   	minChars: 4,
														selectFirst: false,
														extraParams: {
															code: function(){ return chosenLanguage.val(); }
														}
												   });
				title.result(function(evt, data, formatted) {
					var chosenStatementId = data[1];
				});
				
			}

			// Public API functions
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