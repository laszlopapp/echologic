(function($, window, undefined){
 
  $.fn.statement = function(settings) {
    
    function Statement(elem, s) {
      
			var jsp = this;
		
      initialise(s);

      function initialise(s) {
        
        
        if (s['load']) {
          insertStatement(s);
	        /* Navigation through Siblings */
	        loadSession(elem);
	        initNavigationButton(elem.find(".header a.prev"), -1); /* Prev */
	        initNavigationButton(elem.find(".header a.next"),  1); /* Next */
				}
				
				initExpandables(elem, s);
				

        /* Statement Form Helpers */
        if(elem.is('form')) {
          loadRTEEditor(elem);

          /*New Statement Form Helpers */
          if (elem.hasClass('new')) {
            hideNewStatementType(elem);
            loadDefaultText(elem);
            handleStatementFormsSubmit(elem);
            initFormCancelButton(elem);
            if (elem.hasClass(settings['echoableClass'])) {
              initEchoButton(elem);
            }
          }

          /* Taggable Form Helpers */
          if (elem.hasClass(settings['taggableClass'])) {
            loadTags(elem);
            loadTagEvents(elem);
            loadStatementAutoComplete(elem);
          }
					
					if (elem.hasClass('follow_up_question')) {
						initFollowUpQuestionFormEvents(elem);
					}
        }
        else {
          /* Sidebar Add Button */
          initAddNewButton(elem, s);
          /* Pagination */
          initMoreButton(elem);
          initStatementHistoryEvents(elem);
					initFollowUpQuestionEvents(elem);
          /* Message Alerts */
					if (s['load']) {
            loadMessageBoxes(elem, s);
					}
        }
      }
      
      // Auxiliary functions
      var timer = null;


      function insertStatement(settings) {
				//if ($('div#statements').find('> #' + elem.attr('id')).length > 0) {return;}
				
				if (!settings['insertStatement']){return;}
				
				var element = $('div#statements .statement').eq(settings['level']);
				if(element.length > 0) {
          element.replaceWith(elem);
        }
        else
        {
          hideStatements(settings);
          $('div#statements').append(elem);
        }
			}

      function initExpandable(expandable, settings) {
				var content = expandable.attr('data-content');
        var path = expandable.attr('href');
    
		    
		    if (!content) {return;}
		
        expandable.data('content', content);
        expandable.data('path', path);
    
        expandable.removeAttr('data-content');
        expandable.removeAttr('href');
        
        
        /* Special ajax event for the statement (collapse/expand)*/
        expandable.bind("click", function(){
          
          var element = $(this);
          var to_show = element.parents("div:first").find($(this).data('content'));
					if (to_show.length > 0) {
						/* if statement already has loaded content */
            supporters_label = element.find('.supporters_label');
						element.toggleClass('active');
						to_show.animate(toggleParams, settings['animation_speed']);
						supporters_label.animate(toggleParams, settings['animation_speed']);
          }
          else
          {
            /* load the content that is missing */
            href = $(this).data('path');
      
            $.getScript(href, function(e) {
              element.addClass('active');
            });
          }
          return false;
        });
			}
			
      function initExpandables(statement, settings) {
				statement.find(".ajax_expandable").each(function(){
			    initExpandable($(this), settings);
			  });
			
			  
			}

		  /*
		   * Sets the Timer for the Message Boxes to show up (p.ex., the translation message box)
		   */
		  function loadMessageBoxes(statement, settings) {
		    var messageBox = statement.find('.message_box');
		    if (timer != null) {
		      clearTimeout (timer);
		      messageBox.stop(true).hide;
		    }
		    timer = setTimeout( function(){
		      messageBox.animate(toggleParams, settings['animation_speed']);
		    }, 1500);
		  }
		
		
		
		  /*
		   * collapses all visible statements
		   */
		  function hideStatements(settings) {
		    $('#statements .statement .header').removeClass('active').addClass('ajax_expandable').each(function(){
					initExpandable($(this), settings);
				});
		    $('#statements .statement .content').hide('slow');
		    $('#statements .statement .header .supporters_label').hide();
		  };
		
		  /*
		   * Gets the siblings of the statement and places them in the client session for navigation purposes
		   */
		  function loadSession(statement) {
		    parent = statement.prev();
		    if (parent.length)
		    {
		      /* stores siblings with the parent node id */
		      var parent = parent.attr('id');
		    }else{
		      /* no parent id, that means it's a root node, therefore, stores them into roots */
		      var parent = 'roots';
		    }
		    siblings = eval(statement.attr("data-siblings"));
		    if (siblings != null) {
		      $("div#statements").data(parent, siblings);
		    }
		    statement.removeAttr("data-siblings");
		  }
		
		  /*
		   * Generates the right link for the prev/next button according to the statements stored in session
		   * navigation is circular
		   * element: button ; inc: position of the statement to be added relative to the current statement
		   */
		  function initNavigationButton(element, inc) {
		
		    if (!element || element.length == 0) {return;}
		    current_node_id = element.attr('data-id');
		    node = element.parents('.statement');
		
		    if (current_node_id.match('add')) {
		      aux = current_node_id.split('_');
		      current_node_id = [];
		      /* get parent id */  if(aux[0].match(/\d+/)) {current_node_id.push(aux.shift());}
		      /* get 'add' */  current_node_id.push(aux.shift());
		      current_node_id.push(aux.join('_')); current_node_id = "/"+current_node_id.join('/');
		    } else {current_node_id = eval(current_node_id);}
		    /* get current node statement type */
		    if (node.attr("id").match('add_')) {
		      node_class = node.attr("id").replace('add/','');
		    }
		    else {
		      node_class = node.attr("id").match(/[a-z]+(?:_[a-z]+)?/);
		      node_class = node_class[0].replace('edit_',''); //edit form has prev/next buttons too!!
		    }
		    /* get parent node from the visited node */
		    parent_node = node.prev();
		    /* get id where the current node's siblings are stored */
		    if(parent_node.length > 0)
		    {
		      parent_path = parent_node_id = parent_node.attr('id');
		    } else {
		      parent_node_id = 'roots';
		      parent_path = '';
		    }
		    /* get siblings ids */
		    siblings_ids = $("div#statements").data(parent_node_id);
		    /* get index of the prev/next sibling */
		    id_index = (siblings_ids.indexOf(current_node_id) + inc) % siblings_ids.length;
		    //BUG: % operator is not working properly in jquery for negative values (-1%7 => -1)?????????
		    if (id_index < 0) {id_index = siblings_ids.length - 1;}
		
		    new_node_id = new String(siblings_ids[id_index]);
		    /* if 'add' action, then write add link */
		    if (new_node_id.match('add')) {
		      element.attr('href', element.attr('href').replace(/\/\d+.*/, new_node_id));
		    }
		    else {
		      element.attr('href', element.attr('href').replace(/\/\d+.*/, "/" + new_node_id));
		    }
		
		    $(element).removeAttr('data-id');
		  }
		
		
		  /*
		   * SIDEBAR
		   */
		  function initAddNewButton(statement, settings) {
		    statement.find(".action_bar span.add_new_button").bind("click", function() {
		      $(this).parent().next().toggle();
		      return false;
		    
		    });
		    statement.find(".action_bar div#add_new_options").bind("mouseleave", function (){
		      $(this).animate(toggleParams,settings['animation_speed']);
		    });
		  }
		
		  /*
		   * PAGINATION AND HISTORY HANDLING
		   */
		
		  /*
		   * handles the click on the more Button event (replaces it with an element of class 'more_loading')
		   */
		  function initMoreButton(statement) {
		    statement.find(".more_pagination a").bind("click", function() {
					$(this).replaceWith($('<span/>').text($(this).text()).addClass('more_loading'));
		    });
		  }
		
		  /* 
		   * handles the follow up question related events(click on the statement's fuq child, new fuq button, 
		   * and fuq form's cancel button
		   */
		  function initFollowUpQuestionEvents(statement) {

			  /* FOLLOW-UP QUESTION CHILD */
			  statement.find("#follow_up_questions.children a.statement_link").bind("click", function(){
			    var question = $(this).parent().attr('id').replace(/[^0-9]+/, '');
			    var bids = $('#breadcrumbs').breadcrumb('getBreadcrumbStack', $(this));
			
			    var last_bid = bids[bids.length-1];
			
			    /* set fragment */
			    $.setFragment({
			      "bids": bids.join(','),
			      "sids": question,
			      "new_level": true,
			      "prev": last_bid
			    });
			    return false;
			  });
			
			
			  /* NEW FOLLOW-UP QUESTION BUTTON (ON CHILDREN AND SIDEBAR)*/
			  statement.find("a.create_follow_up_question_button").bind("click", function(){
			    var bids = $('#breadcrumbs').breadcrumb('getBreadcrumbStack', $(this));
			
			    /* set fragment */
			    $.setFragment({
			      "bids": bids.join(','),
			      "new_level": true
			    });
			  });
			}
			
			function initFollowUpQuestionFormEvents(statement) {
				statement.find("a.cancel_text_button").("click", function(){
          var bids = $('#breadcrumbs').breadcrumb('getBreadcrumbStack', null);
      
          /* get last breadcrumb id */
          var last_bid = bids[bids.length-1].split('=>').pop();
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
            var prev_bid = bid_to_delete.parent().prev().find('a');
            if (prev_bid && prev_bid.hasClass('statement')) {
              prev_bid = "fq=>" + prev_bid.attr('id').match(/\d+/);
            }
            else
            {
              prev_bid = "";
            }
      
            bids.pop();
            $.setFragment({
              "bids": bids.join(','),
              "new_level": true,
              "prev": prev_bid
            });
            return false;
          }
        });
			}
		
		  /*
		   * Sets the different links on the statement view handling, after the user clicked on them (fragment history handling)
		   */
		  function initStatementHistoryEvents(statement){
				/****************************/
		    /* prev/next buttons, title */
		    /****************************/
		    statement.find('.header a.statement_link').bind("click", function(){
		      var current_stack = getStatementsStack(this, false);
					
		      /* set fragment */
		      $.setFragment({
		        "sids": current_stack.join(','),
		        "new_level": ''
		      });
		      return false;
		    });
		
		    /**************/
		    /* child link */
		    /**************/
				/* Note: this handler is for only not follow up question child link. fuq's have their own handler */
		    statement.find('.children a.statement_link:not(.follow_up_question_link)').bind("click", function(){
		      var current_stack = getStatementsStack(this, true);
		      /* set fragment */
		      $.setFragment({
		        "sids": current_stack.join(','),
		        "new_level": true
		      });
		      return false;
		    });
		  }
		
		
		  /*
		   * returns an array of the statement ids that should be loaded to the stack after 'element' was clicked
		   * (and a new statement is loaded)
		   * element: HTML element that was clicked ; new_level: true or false (child statement link)
		   */
		  function getStatementsStack(element, new_level) {
		    /* get the statement element */
		    var statement = $(element).parents('.statement');
		    /* get statement id current index in the list of statements */
		    var statement_index = $('#statements .statement').index(statement);
		
		    /* get soon to be visible statement */
		    var path = element.href.split("/");
		    var id = path.pop().split('?').shift();
		
		    if (id.match(/\d+/)) {
		      var current_sids = id;
		    } else {
		      /* add teaser case */
		      /* when there's a parent id attached, copy :id/add/:type, or else, just copy the add/:type */
		      var index_backwards = path[path.length - 2].match(/\d+/) ? 2 : 1;
		      var current_sids = path.splice(path.length - index_backwards, 2);
		      current_sids.push(id);
		      current_sids = current_sids.join('/');
		    }
		    current_stack = [];
		
		    /* get current_stack of visible statements (if any matches the clicked statement, then break) */
		    $("#statements .statement").each( function(index){
		      if (index < statement_index) {
		        id = $(this).attr('id').split('_').pop();
		        if(id.match("add")){
		          id = "add/" + id;
		        }
		        current_stack.push(id);
		      } else if (index == statement_index) {
		         if (new_level) {
		          current_stack.push($(this).attr('id').split('_').pop());
		         }
		        }
		    });
		    /* insert clicked statement */
		    current_stack.push(current_sids);
		    return current_stack;
		  }
		
		  /*
		   * FORM HELPERS
		   */
		
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
		        "sids": new_sids.join(",")
		      }));
		    }
		    
		    
		  }
		
		  /*
		   * loads the statement text RTE editor
		   */
		  function loadRTEEditor(form) {
		    var textArea = form.find('textarea.rte_doc, textarea.rte_tr_doc');
		    defaultText = textArea.attr('data-default');
		
		    parent_node = textArea.parents('.statement');
		    url = 'http://' + window.location.hostname + '/stylesheets/';
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
		
		  /*
		   * Initializes echo button click handling on new statement forms
		   */
		  function initEchoButton(form) {
		    form.find('div#echo_button .new_record.not_supported').bind('click', function(){
		      supportEchoButton($(this));
		    });
		    form.find('div#echo_button .new_record.supported').bind('click', function(){
		      unsupportEchoButton($(this));
		    });
		  }
		
		  /*
		   * triggers all the visual events associated with a support from an echo statement
		   */
		  function supportEchoButton(button) {
		    form = button.parents('form.statement');
		    updateEchoButton(form, button, 'supported', 'not_supported');
		    form.find('#echo').val(true);
		    updateSupportersNumber(form,'1');
		    updateSupportersBar(form, 'echo_indicator', 'no_echo_indicator', '10');
		  }
		
		  /*
		   * triggers all the visual events associated with an unsupport from an echo statement
		   */
		  function unsupportEchoButton(button) {
		    var form = button.parents('form.statement');
		    updateEchoButton(form, button, 'not_supported', 'supported');
		    form.find('#echo').val(false);
		    updateSupportersNumber(form,'0');
		    updateSupportersBar(form, 'no_echo_indicator', 'echo_indicator', '0');
		  }
		
		  function updateEchoButton(form, button, classToAdd, classToRemove) {
		    button.removeClass(classToRemove).addClass(classToAdd);
		    info(form.find('.action_bar').data('messages')[classToAdd]);
		  }
		  function updateSupportersNumber(form, value) {
		    var supporters_label = form.find('.supporters_label');
		    var supporters_text = supporters_label.text();
		    supporters_label.text(supporters_text.replace(/[0-9]/, value));
		  }
		  function updateSupportersBar(form, classToAdd, classToRemove, ratio) {
		    var old_supporter_bar = form.find('.supporters_bar');
		    var new_supporter_bar = $('<span></span>').attr('class', old_supporter_bar.attr('class')).addClass(classToAdd).removeClass(classToRemove).attr('alt', ratio);
		    new_supporter_bar.attr('title', form.find('.supporters_label').text());
		    old_supporter_bar.replaceWith(new_supporter_bar);
		  }
		
		  /***************/
		  /* Tag Helpers */
		  /***************/
		
		
		  /*
		   * load this current statement's already existing tags into the tags input box
		   */
		  function loadTags(form) {
		    tags_to_load = form.find('input.question_tags').val();
		    tags_to_load = $.trim(tags_to_load);
		    tags_to_load = tags_to_load.split(',');
		    while (tags_to_load.length > 0) {
		      tag = $.trim(tags_to_load.shift());
		      if (tag.localeCompare(' ') > 0) {
		        element = createTagButton(form, tag, form.find(".question_tags"));
		        form.find('#question_tags_values').append(element);
		      }
		    }
		  }
		  /*
		   * adds event handling to all the possible interactions with the tags box
		   */
		  function loadTagEvents(form) {
		    /* Pressing 'enter' button */
		    form.find('#tag_topic_id').bind('keypress', (function(event) {
		      form = $(this).parents('form.statement');
		      if (event && event.keyCode == 13) { /* check if enter was pressed */
		        if (form.find('#tag_topic_id').val().length != 0) {
		          form.find('.addTag').click();
		        }
		        return false;
		      }
		    }));
		
		    /* Clicking 'add tag' button */
		    form.find('.addTag').bind('click', (function() {
		      form = $(this).parents('form.statement');
		      entered_tags = form.find('#tag_topic_id').val().trim().split(",");
		      if (entered_tags.length != 0) {
		        /* Trimming all tags */
		        entered_tags = jQuery.map(entered_tags, function(tag) {
		          return (tag.trim());
		        });
		        existing_tags = form.find('.question_tags').val();
		        existing_tags = existing_tags.split(',');
		        existing_tags = $.map(existing_tags,function(q){return q.trim()});
		
		        new_tags = new Array(0);
		        while (entered_tags.length > 0) {
		          tag = entered_tags.shift().trim();
		          if (existing_tags.indexOf(tag) < 0 && entered_tags.indexOf(tag) < 0) {
		            if (tag.localeCompare(' ') > 0) {
		              element = createTagButton(form, tag, ".question_tags");
		              $('#question_tags_values').append(element);
		              new_tags.push(tag);
		            }
		          }
		        }
		        question_tags = form.find('.question_tags').val();
		        if (new_tags.length > 0) {
		          question_tags = ((question_tags.trim().length > 0) ? question_tags + ',' : '') + new_tags.join(',');
		          form.find('.question_tags').val(question_tags);
		        }
		        form.find('#tag_topic_id').val('');
		        form.find('#tag_topic_id').focus();
		      }
		    }));
		  }
		
		  /*
		   * Aux: Creates the statement tag HTML Element
		   * text: tag text ; tags_class: css class of the tags hidden input container
		   */
		  function createTagButton(form, text, tags_class) {
		    element = $('<span/>').addClass('tag');
		    element.text(text);
		    deleteButton = $('<span class="delete_tag_button"></span>');
		    deleteButton.click(function(){
		      $(this).parent().remove();
		      tag_to_delete = $(this).parent().text();
		      form_tags = form.find(tags_class).val();
		      form_tags = form_tags.split(',');
		      form_tags = $.map(form_tags,function(q){return q.trim()});
		      index_to_delete = form_tags.indexOf(tag_to_delete);
		      if (index_to_delete >= 0) {
		        form_tags.splice(index_to_delete, 1);
		      }
		      form.find(tags_class).val(form_tags.join(','));
		    });
		    element.append(deleteButton);
		    return element;
		  }
		
		  /*
		   * Initializes auto_complete property for the tags text input
		   */
		  function loadStatementAutoComplete(form) {
		    form.find('.tag_value_autocomplete').autocomplete('../../discuss/auto_complete_for_tag_value', {minChars: 3, selectFirst: false});
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
		   * Hides the statement type on new statement forms
		   */
		  function hideNewStatementType(element) {
		    input_type = element.find('input#type');
		    input_type.data('value',input_type.attr('value'));
		    input_type.removeAttr('value');
		  }
		
		  /*
		   * Shows the statement type on new statement forms
		   */
		  function showNewStatementType(element) {
		    input_type = element.find('input#type');
		    input_type.attr('value', input_type.data('value'));
		  }
	
      // Public API
      $.extend(jsp, 
      {
        reinitialise: function(s)
        {
          s = $.extend({}, s, settings, {'load' : false});
          initialise(s);
        },
        // API Functions
        insertContent: function(content){
		      elem.append(content);
					return this;
		    },
		
		    removeBelow: function(){
		     elem.nextAll().each(function(){
			     /* delete the session data relative to this statement first */
			     $('div#statements').removeData(this.id);
			     $(this).remove();
					 
		     });
				 return this;
		    },
        insert: function() {
		      var element = $('div#statements .statement').eq(settings['level']);
		      if(element.length > 0) {
		        element.replaceWith(elem);
		      }
		      else
		      {
		        hideStatements(settings);
		        $('div#statements').append(elem);
		      }
					return this;
		    },
		    loadAuthors: function (authors, length){
		      authors.insertAfter(elem.find('.summary h2')).animate(toggleParams, settings['animation_speed']);
		      elem.find('#authors_list').jcarousel({
		        scroll: 3,
		        buttonNextHTML: "<div class='next_button'></div>",
		        buttonPrevHTML: "<div class='prev_button'></div>",
		        size: length
		      });
					return this;
		    },
		    updateSupport: function (action_bar, supporters_bar, supporters_label) {
		      elem.find('.action_bar').replaceWith(action_bar);
		      elem.find('.supporters_bar:first').replaceWith(supporters_bar);
		      elem.find('.supporters_label').replaceWith(supporters_label);
					return this;
		    },
		    insertMore: function (level, type_id) {
		      var element = $('#statements div.statement:eq(' + level + ') ' + type_id + ' .headline');
		      elem.insertAfter(element).animate(toggleParams, settings['animation_speed']);
					return this;
		    },
		    loadEchoMessages: function (messages) {
		      elem.find('.action_bar').data('messages', messages);
					return this;
		    },
		    /* Expandable Flow */
		    show: function(){
		      elem.find('.content').animate(toggleParams, settings['animation_speed']);
					return this;
		    },
		    hide: function () {
		      elem.find('.header').removeClass('active').addClass('ajax_expandable');
		      elem.find('.content').hide('slow');
		      elem.find('.supporters_label').hide();
					return this;
		    }
      });
	  }
      
			
	  $.fn.statement.defaults = {
      'animation_speed': 500,
      'taggableClass' : 'taggable',
      'echoableClass' : 'echoable', 
      'level' : 0,
			'insertStatement' : true,
			'load' : true
    };
		
    // Pluginifying code...
    settings = $.extend({}, $.fn.statement.defaults, settings);

    var ret;
    this.each(function(){
    
      var elem = $(this), api = elem.data('api');
      if (api) {
        api.reinitialise(settings);
      } else {
      api = new Statement(elem, settings);
        elem.data('api', api);
      }
      ret = ret ? ret.add(elem) : elem;
    })
    return ret;
    
    
  };
  
})(jQuery,this);
      
      
 