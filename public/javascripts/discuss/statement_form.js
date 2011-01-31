(function($) {

  $.fn.statementForm = function(currentSettings) {

    $.fn.statementForm.defaults = {
      'animation_speed': 500,
      'taggableClass' : 'taggable'
    };

    // Merging settings with defaults
    var settings = $.extend({}, $.fn.statementForm.defaults, currentSettings);

    // Creating and binding the statement form API
    var api = this.data('statementFormApi');
    if (api) {
      api.reinitialise(settings);
    } else {
      api = new StatementForm(this);
      this.data('statementFormApi', api);
    }
    return this;


    /******************************/
    /* The statement form handler */
    /******************************/

    function StatementForm(form) {

			initialise();

			function initialise() {
			  loadRTEEditor();

        // New Statement Form Helpers
        if (form.hasClass('new')) {
          hideNewStatementType();
          loadDefaultText();
          handleStatementFormsSubmit();
          initFormCancelButton();
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
        var defaultText = textArea.attr('data-default');
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

        // Text Inputs
        var inputText = form.find("input[type='text']");
        var value = inputText.attr('data-default');
        if (inputText.val().length == 0) {
          inputText.toggleVal({
            populateFrom: 'custom',
            text: value
          });
        }
        inputText.removeAttr('data-default');
        inputText.blur();


        // Text Area (RTE Editor)
        var editor = form.find("iframe.rte_doc");
        value = editor.attr('data-default');
        var doc = editor.contents().get(0);
        var text = $(doc).find('body');
        if(text.html().length == 0 || text.html().val() == '</br>') {
          var label = $("<span class='defaultText'></span>").html(value);
          label.insertAfter(editor);

          $(doc).bind('click', function(){
            label.hide();
          });
          $(doc).bind('blur', function(){
            var new_text = $(editor.contents().get(0)).find('body');
            if (new_text.html().length == 0 || new_text.html().val() == '</br>') {
              label.show();
            }
          });
        }
        editor.removeAttr('data-default');

        // Clean text inputs on submit
        form.bind('submit', (function() {
          $(this).find(".toggleval").each(function() {
            if($(this).val() == $(this).data("defText")) {
              $(this).val("");
            }
          });
        }));
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