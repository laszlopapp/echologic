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
			var title = form.find('.statement_title input');
			var text;
			var chosenLanguage = form.find('select.language_combo');
			var statementLinked = form.find('input.statement_id');
			var auto_complete_button = form.find('.header .auto_complete');
      var linking_messages;
			
			initialise();

			function initialise() {
				          

				loadRTEEditor();

        // New Statement Form Helpers
        if (form.hasClass('new')) {
          hideNewStatementType();
          loadDefaultText();
          handleStatementFormsSubmit();
          initFormCancelButton();
					initAutoCompleteTitle();
					handleChangeText();
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
				textArea = form.find('textarea.rte_doc, textarea.rte_tr_doc');
				if (!isMobileDevice()) {
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
					
					text = $(form.find('iframe.rte_doc').contents().get(0)).find('body');
				} else {
          text = textArea;					
				}
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

      function toggleAutoCompleteButton(to_add, to_remove) {
				auto_complete_button.addClass(to_add).removeClass(to_remove).text(linking_messages[to_add]);
			}
			
			function activateAutoCompleteButton() {
				toggleAutoCompleteButton('on','off');
			}
			
			function deactivateAutoCompleteButton() {
				toggleAutoCompleteButton('on','off');
			}

      function initAutoCompleteTitle() {
				
				linking_messages = {
					'on' : auto_complete_button.attr('linking_on'),
					'off': auto_complete_button.attr('linking_off')
				}
				
				auto_complete_button.removeAttr('linking_on').removeAttr('linking_off');
				
				var auto_complete_api = title.autocompletes('../../statements/auto_complete_for_statement_title',
							                    {
															   	minChars: 4,
																	selectFirst: false,
																	multipleSeparator: "",
																	extraParams: {
																		code: function(){ return chosenLanguage.val(); }
																	}
												        });
				title.result(function(evt, data, formatted) {
					if (data) {
				  	linkStatement(data[1]);
				  }
				});

        auto_complete_button.bind('click', function(){
          if ($(this).hasClass('on')) {
            // TODO: Right now, nothing happens. But wouldn't it be better to just unlink the statement? 
            // (the visual elements (text, tags...) would remain, just the statement id reference would be lost.
            // this way, we could unlink a wrongly unlinked statement and link it again
            // unlinkStatement();
          }
          else 
          if ($(this).hasClass('off')) {
            title.search();
          }
          
        });
				
			}
			
			function linkStatement(statementId) {
				var path = '../../statements/link_statement/' + statementId;
				path = $.queryString(path, {
					"code" : chosenLanguage.val()
				});
				$.getJSON(path, function(data) {
					var statementText = data['text'];
					var statementTags = data['tags'];
					var statementState = data['editorial_state'];
					
					if(text && text.is('textarea')) {
						text.val(statementText);
					} else {
						text.empty().text(statementText).click().blur();
					}
					
					if (form.hasClass(settings['taggableClass'])) {
				  	form.data('taggableApi').addTags(statementTags);
				  }
					
					$('input:radio[value=' + statementState + ']').attr('checked', true);
					
					statementLinked.val(statementId);
					
					activateAutoCompleteButton();
				});
			}
			
			function unlinkStatement()
			{
				statementLinked.val('');
        deactivateAutoCompleteButton();
			}
		
			
			function handleChangeText() {
				title.bind('change', function(){
					if (statementLinked.val()) {
              unlinkStatement();
            }
				});
				if (text && text.is('textarea')) {
		      text.bind('change', function(){
						if (statementLinked.val()) {
							unlinkStatement();
						}
					});
				} else {
					text.bind('DOMSubtreeModified', function(){
						if (statementLinked.val() && text && text.html().length > 0) {
							unlinkStatement();
						}
					});
				}
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