(function($, window, undefined){

  $.fn.statement_form = function(settings) {

    function StatementForm(elem, s){
	
			var jsp = this;
			
			initialise(s);
			
			function initialise(s){
			  loadRTEEditor(elem);

        /*New Statement Form Helpers */
        if (elem.hasClass('new')) {
          hideNewStatementType(elem);
          loadDefaultText(elem);
          handleStatementFormsSubmit(elem);
          initFormCancelButton(elem);
          
        }

        /* Taggable Form Helpers */
        if (elem.hasClass(settings['taggableClass'])) {
          elem.taggable();
        }
        
        if (elem.hasClass('follow_up_question')) {
          initFollowUpQuestionFormEvents(elem);
        }
			}
			
			//Auxiliary Functions
			
			/*
       * loads the statement text RTE editor
       */
      function loadRTEEditor(form) {
        var textArea = form.find('textarea.rte_doc, textarea.rte_tr_doc');
        defaultText = textArea.attr('data-default');
    
        parent_node = textArea.parents('.statement');
				url = 'http://' + window.location.host + '/stylesheets/';
        textArea.rte({
          css: ['jquery.rte.css'],
          base_url: url,
          frame_class: 'wysiwyg',
          controls_rte: rte_toolbar,
          controls_html: html_toolbar
        });
        parent_node.find('.focus').focus();
    
        /* for default text */
        parent_node.find('iframe').attr('data-default', defaultText);
      }
			
			/*
       * Hides the statement type on new statement forms
       */
      function hideNewStatementType(element) {
        input_type = element.find('input#type');
        input_type.data('value',input_type.attr('value'));
        input_type.removeAttr('value');
      }
			
			
			/*
       * Loads Form's Default Text to title, text and tags
       */
			function loadDefaultText(form) {
        if (!form.hasClass('new')) {return;}
    
    
        /* Text Inputs */
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
    
    
        /* Text Area (RTE Editor) */
        var editor = form.find("iframe.rte_doc");
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
        form.bind('submit', (function() {
          $(this).find(".toggleval").each(function() {
            if($(this).val() == $(this).data("defText")) {
              $(this).val("");
            }
          });
        }));
      }
			
			
			function handleStatementFormsSubmit(form) {
        form.bind('submit', (function(){
          showNewStatementType(form);
          $.ajax({
            url: this.action,
            type: "POST",
            data: $(this).serialize(),
            dataType: 'script',
            success: function(data, status){
              hideNewStatementType(form);
            }
          });
          return false;
        }));
      }
			
			/*
       * Handles Cancel Button click on new statement forms
       */
      function initFormCancelButton(form) {
        var cancelButton = form.find('.buttons a.cancel');
        if ($.fragment().sids) {
          var sids = $.fragment().sids;
          var new_sids = sids.split(",");
          var path = "/" + new_sids[new_sids.length-1];
    
          new_sids.pop();
    
          cancelButton.addClass("ajax");
          cancelButton.attr('href', $.queryString(cancelButton.attr('href').replace(/\/\d+/, path), {
            "sids": new_sids.join(","), 
						"origin": $.fragment().origin
          }));
        }
      }
			
			
        
      function initFollowUpQuestionFormEvents(statement) {
        statement.find("a.cancel_text_button").bind("click", function(){
          var bids = $('#breadcrumbs').data('api').getBreadcrumbStack(null);
      
          /* get last breadcrumb id */
					var last_bid = bids[bids.length-1];
					
          /* get last statement view id (if teaser, parent id + '/' */
          var last_sid = $.fragment().sids;
          if (last_sid) {
            last_sid = $.fragment().sids.split(',').pop().match(/\d+\/?/).shift();
          } else {
            last_sid = '';
          }
					if (last_bid.match(last_sid)) { /* create follow up question button was pressed */
            var bid_to_delete = $('#breadcrumbs a.statement:last');
            $('#breadcrumbs').data('to_delete', [bid_to_delete.attr('id')]);
      
            /* get previous bid in order to load the proper siblings to session */
						var new_level = $.fragment().new_level;
						
						if (new_level == 'true') {
							var origin_bid = bid_to_delete.parent().prev().find('a');
						} else {
							var origin_bid = bid_to_delete;
						}
						
            if (origin_bid && origin_bid.hasClass('statement')) {
              origin_bid = "fq" + origin_bid.attr('id').match(/\d+/);
            }
            else
            {
              origin_bid = "";
            }
						
      
            bids.pop();
            $.setFragment({
              "bids": bids.join(','),
              "new_level": true,
              "origin": origin_bid
            });
            return false;
          }
        });
      }
			
			/*
       * Shows the statement type on new statement forms
       */
      function showNewStatementType(element) {
        input_type = element.find('input#type');
        input_type.attr('value', input_type.data('value'));
      }
			
			// API Functions
			
			$.extend(jsp, 
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
    api = new StatementForm(elem, settings);
      elem.data('statementFormApi', api);
    }
    ret = ret ? ret.add(elem) : elem;
    
    return ret;
    
    
  };
})(jQuery,this);