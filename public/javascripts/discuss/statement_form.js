(function($) {

  $.fn.statementForm = function(currentSettings) {

    $.fn.statementForm.defaults = {
      'animation_speed': 500,
      'taggableClass' : 'taggable',
			'selected_color' : '#999999'
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
			var type = $.trim(form.find('input#type').val());
			var text;
			var language_combo;
			var chosenLanguage = form.find('select.language_combo');
			var statementLinked = form.find('input.statement_id');
			var publish_checkbox = form.find('.publish_radios');
			var auto_complete_button;
      var linking_messages;
		  var linkedTags;
			var linkedTitle, linkedText;
			
			initialise();

			function initialise() {

				loadRTEEditor();

        if (form.hasClass('embeddable')) {
					form.embeddable();
        }

        // New Statement Form Helpers
        if (form.hasClass('new')) {
					language_combo = form.find('.statement_language select');
          loadDefaultText();
          initFormCancelButton();
					initAutoCompleteTitle();
					handleContentChange();
					unlinkStatement();
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
       * Loads the form's default texts for title, text and tags.
       */
			function loadDefaultText() {
        if (!form.hasClass('new')) {return;}

        form.placeholder();

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
					
					var bids = $.fragment().bids;
					var bids = bids ? bids.split(',') : [];
					var current_bids = $('#breadcrumbs').data('breadcrumbApi').getBreadcrumbStack(null);

					var i = -1;
					$.map(bids, function(a, index){
						if($.inArray(a, current_bids) == -1) {
							i = index;
							return false;
						}
					});
					
					var bids_to_load = i > -1 ? bids.splice(i, bids.length) : [];
					
          cancelButton.addClass("ajax");
          cancelButton.attr('href', $.queryString(cancelButton.attr('href').replace(/\/\d+/, path), {
            "sids": new_sids.join(","),
            "bids": bids_to_load.join(','),
						"origin": $.fragment().origin
          }));
        }
      }

      /**********************/
      /* Statement Linking  */
      /**********************/

      /*
       * updates the auto complete button with css classes and a new label
       */
      function toggleAutoCompleteButton(to_add, to_remove) {
				auto_complete_button.addClass(to_add).removeClass(to_remove).text(linking_messages[to_add]);
			}
			
			
			/*
       * turns the auto complete button green and with the label 'linked'
       */
			function activateAutoCompleteButton() {
				toggleAutoCompleteButton('on','off');
			}
			
			/*
       * turns the auto complete button grey and with the label 'link'
       */
			function deactivateAutoCompleteButton() {
				toggleAutoCompleteButton('off','on');
			}

      /*
       * initializes the whole title auto completion behaviour
       */
      function initAutoCompleteTitle() {

        // gets the auto complete button				
				auto_complete_button = form.find('.header .auto_complete');
				
				// loads the labels 
				linking_messages = {
					'on' : auto_complete_button.attr('linking_on'),
					'off': auto_complete_button.attr('linking_off')
				}
				
				auto_complete_button.removeAttr('linking_on').removeAttr('linking_off');
				
				
				// initializes the autocompletion plugin 
				var auto_complete_api = title.autocompletes('../../statements/auto_complete_for_statement_title',
							                    {
															   	minChars: 100,
																	selectFirst: false,
																	multipleSeparator: "",
																	extraParams: {
																		code: function(){ return chosenLanguage.val(); },
																	  type: type
																	}
												        });
		    
				// handles the selection of an auto completion results entry
				title.result(function(evt, data, formatted) {
					if (data) {
				  	linkStatement(data[1]);
				  }
				});

        // what happens when i click the auto completion button
        auto_complete_button.bind('click', function(){
          if ($(this).hasClass('on')) {
            // TODO: Right now, nothing happens. But wouldn't it be better to just unlink the statement? 
            // (the visual elements (text, tags...) would remain, just the statement id reference would be lost.
            // this way, we could unlink a wrongly unlinked statement and link it again
            // unlinkStatement();
          }
          else 
          if ($(this).hasClass('off')) {
						var titleValue = title.val();
						if (isEchoStatementUrl(titleValue)) {
							var echoId = titleValue.match("statement/([0-9]+).*")[1];
							linkStatementNode(echoId);
						}
						else {
							title.addClass('ac_loading');
							title.search();
						}
          }
          
        });
				
			}
			
			/*
       * given a statement node Id, gets the statement remotely and fills the form with the given data
       */
			function linkStatementNode(nodeId) {
				var path = '../../statement/' + nodeId + '/link_statement_node';
        path = $.queryString(path, {
          "code" : chosenLanguage.val()
        });
        $.getJSON(path, function(data) {
          linkStatementData(data);

        });
			}
			
			
			/*
       * given a statement Id, gets the statement remotely and fills the form with the given data
       */
			function linkStatement(statementId) {
				
				var path = '../../statement/' + statementId + '/link_statement';
				path = $.queryString(path, {
					"code" : chosenLanguage.val()
				});
				$.getJSON(path, function(data) {
					linkStatementData(data);


          // Embedded Data
					if (form.hasClass('embeddable')) {
						form.data('embeddableApi').linkEmbeddedContent(data);
					}
				});
			}
			
			function linkStatementData(data) {
				statementId = data['id'];
				linkedTitle = data['title']; // used for the key pressed event
        linkedText = data['text'];
        var statementTags = data['tags'];
        var statementState = data['editorial_state'];

        // write title
        if (title.val() != linkedTitle) {
          title.val(linkedTitle);
        }
        
        // disable language combo
        language_combo.attr('disabled', true);
      
        // fill in summary text 
        if(text && text.is('textarea')) {
          text.val(linkedText);
        } else {
          text.empty().text(linkedText).click().blur();
        }
        
        // fill in tags
        if (form.hasClass(settings['taggableClass'])) {
          linkedTags = statementTags;
          form.data('taggableApi').removeAllTags().addTags(statementTags);
        }
        
        // check right editorial state and disable the radio buttons
        publish_checkbox.find('input:radio[value=' + statementState + ']').attr('checked', true);
        publish_checkbox.find('input:radio').attr('disabled', true);
                  
        // activate auto complete button
        activateAutoCompleteButton();
        
        form.addClass('linked');
        
        //TODO: Not working when text is inside the iframe!!!
        if (!isMobileDevice()) {
          text.addClass('linked');
        }
        
        // link statement Id
        statementLinked.val(statementId);
			}
			
			/*
       * unlink the previously linked statement (delete statement Id field and deactivate auto completion button
       */
			function unlinkStatement()
			{
				linkedTitle = null;
				linkedText = null;
				statementLinked.val('');
        deactivateAutoCompleteButton();
				form.removeClass('linked');
				
				// disable language combo
        language_combo.removeAttr('disabled');
				
				//TODO: Not working when text is inside the iframe!!!
				if (!isMobileDevice()) {
          text.removeClass('linked');
        }
				
				// enable editorial state buttons
				$('.publish_radios input:radio').removeAttr('disabled');
				
				
				// Uncomment if unlinking is supposed to make the info contents disappear
				/*
				if (form.hasClass('embeddable') {
				  form.unlinkEmbeddedContent();
				}
				*/
			}
		
			
			/*
       * handles the event of writing new content in one of the fields (in the case, has to unlink a previously unlinked statement)
       */
			function handleContentChange() {
				// title
				title.bind('keypress', function(){
					if (statementLinked.val()) {
						  if (title.val() != linkedTitle) {
							 unlinkStatement();	
							}
            }
				});
				
				// text
				if (text && text.is('textarea')) {
		      text.bind('keypress', function(){
						if (statementLinked.val()) {
							if (text.val() != linkedText) {
						  	unlinkStatement();
						  }
						}
					});
				} else {
					text.bind('DOMSubtreeModified', function(){
						if (statementLinked.val() && text && text.html().length > 0) {
							unlinkStatement();
						}
					});
				}
				
				//tags
				form.bind('tagremoved', function(event, tag){
					if (statementLinked.val()) {
						if ($.inArray(tag, linkedTags) != -1) {
							unlinkStatement();
						}
					}
				});
				
				form.bind('unlink', function(){
					if (statementLinked.val()) {
						unlinkStatement();
		      }
				});
				
				if (form.hasClass('embeddable')) {
					form.data('embeddableApi').handleContentChange('unlink');
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