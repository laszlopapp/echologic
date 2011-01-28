(function($, window, undefined){

  $.fn.statement_form = function(settings) {

    function StatementForm(stForm){
	    var statementForm = stForm; 
			
			initialise();
			
			function initialise(){
			  loadRTEEditor();

        /*New Statement Form Helpers */
        if (elem.hasClass('new')) {
          hideNewStatementType();
          loadDefaultText();
          handleStatementFormsSubmit();
          initFormCancelButton();
          
        }

        /* Taggable Form Helpers */
        if (statementForm.hasClass(settings['taggableClass'])) {
          elem.taggable();
        }
        
        if (statementForm.hasClass('follow_up_question')) {
					initFollowUpQuestionFormEvents();
        }
			}
			
			//Auxiliary Functions
			
			/*
       * loads the statement text RTE editor
       */
      function loadRTEEditor() {
        var textArea = statementForm.find('textarea.rte_doc, textarea.rte_tr_doc');
        defaultText = textArea.attr('data-default');
    
        url = 'http://' + window.location.host + '/stylesheets/';
        textArea.rte({
          css: ['jquery.rte.css'],
          base_url: url,
          frame_class: 'wysiwyg',
          controls_rte: rte_toolbar,
          controls_html: html_toolbar
        });
        statementForm.find('.focus').focus();
    
        /* for default text */
        statementForm.find('iframe').attr('data-default', defaultText);
      }
			
			/*
       * Hides the statement type on new statement forms
       */
      function hideNewStatementType() {
        input_type = statementForm.find('input#type');
        input_type.data('value',input_type.attr('value'));
        input_type.removeAttr('value');
      }
			
			
			/*
       * Loads Form's Default Text to title, text and tags
       */
			function loadDefaultText() {
        if (!statementForm.hasClass('new')) {return;}
    
    
        /* Text Inputs */
        var inputText = statementForm.find("input[type='text']");
        var value = inputText.attr('data-default');
        if (inputText.val().length == 0) {
          inputText.toggleVal({
            populateFrom: 'custom',
            text: value
          });
        }
        inputText.removeAttr('data-default');
        inputText.blur();
    
    
        /* Text Area (RTE Editor) */
        var editor = statementForm.find("iframe.rte_doc");
          var value = editor.attr('data-default');
        var doc = editor.contents().get(0);
        text = $(doc).find('body');
        if(text.html().length == 0 || html.val() == '</br>') {
          label = $("<span class='defaultText'></span>").html(value);
          label.insertAfter(editor);
    
          $(doc).bind('click', function(){
            label.hide();
          });
          $(doc).bind('blur', function(){
            new_text = $(editor.contents().get(0)).find('body');
            if (new_text.html().length == 0 || new_text.html() == '</br>') {
              label.show();
            }
          });
        }
        editor.removeAttr('data-default');
    
    
        /* Clean text inputs on submit */
        statementForm.bind('submit', (function() {
          $(this).find(".toggleval").each(function() {
            if($(this).val() == $(this).data("defText")) {
              $(this).val("");
            }
          });
        }));
      }
			
			
			function handleStatementFormsSubmit() {
        statementForm.bind('submit', (function(){
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
       * Handles Cancel Button click on new statement forms
       */
      function initFormCancelButton() {
        var cancelButton = statementForm.find('.buttons a.cancel');
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
			
			
        
      function initFollowUpQuestionFormEvents() {
        statementForm.find("a.cancel_text_button").bind("click", function(){
          var bids = $('#breadcrumbs').data('breadcrumbApi').getBreadcrumbStack(null);
					
          /* get last breadcrumb id */
					var last_bid = bids[bids.length-1];
					
          /* get last statement view id (if teaser, parent id + '/' */
          var last_sid = $.fragment().sids;
          if (last_sid) {
            last_sid = $.fragment().sids.split(',').pop().match(/\d+\/?/).shift();
          } else {
            last_sid = '';
          }
					
					
					
					if (getStatementId(last_bid).match(last_sid)) { /* create follow up question button in children had been pressed */
					  var origin_bid = $('#breadcrumbs a.statement:last').parent().prev().find('a').attr('id');
            bids.pop();
            $.setFragment({ "bids": bids.join(','), "new_level": true, "origin": origin_bid });
            return false;
          } else { /* create follow up question button in siblings had been pressed */
					  $.setFragment({ "bids": '', "new_level": true, "origin": last_bid });
            return false;
					}
        });
      }
			
			/*
       * Shows the statement type on new statement forms
       */
      function showNewStatementType() {
        input_type = statementForm.find('input#type');
        input_type.attr('value', input_type.data('value'));
      }
			
			// API Functions
			
			$.extend(this, 
      {
        reinitialise: function(s)
        {
          s = $.extend({}, s, settings);
          initialise(s);
        }
			});
		}


    $.fn.statement_form.defaults = {
      'animation_speed': 500,
			'taggableClass' : 'taggable'
    };

    // Pluginifying code...
    settings = $.extend({}, $.fn.statement_form.defaults, settings);

    var ret;
    
    var elem = $(this), api = elem.data('statementFormApi');
    if (api) {
      api.reinitialise(settings);
    } else {
    api = new StatementForm(elem);
      elem.data('statementFormApi', api);
    }
    ret = ret ? ret.add(elem) : elem;
    
    return ret;
    
    
  };
})(jQuery,this);