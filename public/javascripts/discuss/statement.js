(function($) {

  $.fn.statement = function(current_settings) {

    $.fn.statement.defaults = {
      'level' : 0,
			'insertStatement' : true,
			'load' : true,
      'echoableClass' : 'echoable',
      'animation_speed': 300
    };

    // Merging settings with defaults
    var settings = $.extend({}, $.fn.statement.defaults, current_settings);

    // Creating and binding the statement API
		var statementApi = this.data('api');
    if (statementApi) {
      statementApi.reinitialise(settings);
    } else {
      statementApi = new Statement(this);
      this.data('api', statementApi);
    }
    return this;


    /*************************/
    /* The statement handler */
    /*************************/

    function Statement(statement) {
      var timer = null;
      var statementId = statement.attr('id');

      initialise();

      function initialise() {

        if (settings['load']) {
					insertStatement();
					/* Navigation through siblings */
	        storeSiblings();
					initNavigationButton(statement.find(".header a.prev"), -1); /* Prev */
	        initNavigationButton(statement.find(".header a.next"),  1); /* Next */
				}

				initExpandables();

        if (isEchoable()) {
          statement.echoable();
        }

        /* Statement Form Helpers */
        if(statement.is('form')) {
					statement.statement_form();
        } else {
					/* Sidebar Add Button */
					initAddNewButton();
					/* Pagination */
          initMoreButton();
          initStatementLinks();
					initFUQLinks();
          /* Message Alerts */
					if (settings['load']) {
            loadMessageBoxes();
					}
        }
      }

      // Returns true if the statement is echoable.
      function isEchoable() {
        return statement.hasClass(settings['echoableClass']);
      }

      function insertStatement() {
				if (!settings['insertStatement']){return;}

				var element = $('div#statements .statement').eq(settings['level']);
				if(element.length > 0) {
          element.replaceWith(statement);
        }
        else
        {
          hideStatements(settings);
          $('div#statements').append(statement);
        }
			}

      function initExpandables() {
				statement.find(".expandable").each(function(){
          var expandableElement = $(this);
					if (expandableElement.hasClass('show_siblings_button')) {
            // Siblings button
				  	expandableElement.expandable({
				  		'animation_params': {
				  			'opacity': 'toggle'
				  		}
				  	});
				  } else if (expandableElement.hasClass('header')) {
            // Title "button" in header
						expandableElement.expandable({
              'loading_class': '.header_buttons .loading'
            });
					} else {
            // Children container
				  	expandableElement.expandable();
				  }
			  });
			}

		  /*
		   * Sets the Timer for the Message Boxes to show up (p.ex., the translation message box)
		   */
		  function loadMessageBoxes() {
		    var messageBox = statement.find('.message_box');
				if (!messageBox.is(":visible")) {
			    if (timer != null) {
			      clearTimeout(timer);
			      messageBox.stop(true).hide();
			    }
			    timer = setTimeout( function() {
			      messageBox.animate(toggleParams, settings['animation_speed']);
			    }, 1500);
				}
		  }

		  /*
		   * Collapses all visible statements.
		   */
		  function hideStatements() {
		    $('#statements .statement .header').removeClass('active').addClass('expandable').each(function() {
					$(this).expandable();
				});
		    $('#statements .statement .content').hide();
		    $('#statements .statement .header .supporters_label').hide();
		  }

		  /*
		   * Gets the siblings of the statement and places them in the client for navigation.
		   */
		  function storeSiblings() {
        var key;
		    var parent = statement.prev();
		    if (parent.length) {
		      // Store siblings with the parent node id
		      key = parent.attr('id');
		    } else {
		      // No parent means it's a root node, therefore, store siblings under the key 'roots'
		      key = 'roots';
		    }
		    var siblings = eval(statement.attr("data-siblings"));
		    if (siblings != null) {
		      $("div#statements").data(key, siblings);
		    }
		    statement.removeAttr("data-siblings");
		  }

		  /*
		   * Generates the links for the prev/next buttons according to the siblings stored in the session.
		   * Navigation is circular.
		   *
		   * button: the prev or next button
		   * inc: the statement index relative to the current statement (-1 for prev, 1 for next)
		   */
		  function initNavigationButton(button, inc) {
		    if (!button || button.length == 0) {return;}
				if (button.attr('href').length == 0) {
					button.attr('href', window.location.pathname);
				}

        // Get statement node id to link to
				var currentNodeId = button.attr('data-id');
		    if (currentNodeId.match('add')) {
		      var idParts = currentNodeId.split('_');
		      currentNodeId = [];
		      // Get parent id
          if(idParts[0].match(/\d+/)) {
            currentNodeId.push(idParts.shift());
          }
		      // Get 'add'
          currentNodeId.push(idParts.shift());
		      currentNodeId.push(idParts.join('_'));
          currentNodeId = "/"+currentNodeId.join('/');
		    } else {
          currentNodeId = eval(currentNodeId);
        }
		    // Get statement type of current node
        /*var node_class;
		    if (statement.attr("id").match('add_')) {
		      node_class = statement.attr("id").replace('add/','');
		    } else {
		      node_class = statement.attr("id").match(/[a-z]+(?:_[a-z]+)?/);
          // Edit form has prev/next buttons, too
		      node_class = node_class[0].replace('edit_','');
		    }*/

		    // Get parent element (statement)
		    var parent = statement.prev();
		    // Get id where the current node's siblings are stored
        var parentPath, siblingsKey;
		    if (parent.length > 0) {
		      parentPath = siblingsKey = parent.attr('id');
		    } else {
		      siblingsKey = 'roots';
		      parentPath = '';
		    }

		    // Get siblings ids
		    var siblingIds = $("div#statements").data(siblingsKey);
				// Get index of the prev/next sibling
		    var targetIndex = (siblingIds.indexOf(currentNodeId) + inc + siblingIds.length) % siblingIds.length;

		    var targetNodeId = new String(siblingIds[targetIndex]);
				if (targetNodeId.match('add')) {
          // Add (teaser) link
					button.attr('href', button.attr('href').replace(/\/\d+.*/, targetNodeId));
		    }
		    else {
					button.attr('href', button.attr('href').replace(/\/\d+.*/, "/" + targetNodeId));
		    }

		    button.removeAttr('data-id');
		  }


		  /*
		   * Handles the button to toggle the add new panel for creating new statements.
		   */
		  function initAddNewButton() {
		    statement.find(".action_bar .add_new_button").bind("click", function() {
					$(this).next().animate({'opacity' : 'toggle'}, settings['animation_speed']);
		      return false;

		    });
		    statement.find(".action_bar .add_new_panel").bind("mouseleave", function() {
		      $(this).fadeOut();
          return false;
		    });
		  }

		  /*
		   * PAGINATION AND HISTORY HANDLING
		   */

		  /*
		   * Handles the click on the more Button event (replaces it with an element of class 'more_loading')
		   */
		  function initMoreButton() {
		    statement.find(".more_pagination a:Event(!click)").bind("click", function() {
          var moreButton = $(this);
					moreButton.replaceWith($('<span/>').text(moreButton.text()).addClass('more_loading'));
		    });
		  }


		  /*
		   * Handles the follow up question (FUQ) related events:
		   * - click on the statement's FUQ child
		   * - new FUQ button,
		   * - FUQ form's cancel button
		   */
		  function initFUQLinks() {
        statement.find("#follow_up_questions.children").each(function(){
					initFUQChildrenLinks($(this));
				});

			  // NEW FOLLOW-UP QUESTION BUTTON (ON CHILDREN AND SIDEBAR)
			  statement.find(".action_bar a.create_follow_up_question_button").bind("click", function(){
			    var bids = $('#breadcrumbs').data('api').getBreadcrumbStack($(this));
			    $.setFragment({
			      "bids": bids.join(','),
			      "new_level": true
			    });
			  });
			}

      /* Initializes follow up question children. */
      function initFUQChildrenLinks(fuq_children) {
				fuq_children.find("a.statement_link.follow_up_question_link:Event(!click)").bind("click", function() {
          var question = $(this).parent().attr('id').replace(/[^0-9]+/, '');
          var bids = $('#breadcrumbs').data('api').getBreadcrumbStack($(this));
          var last_bid = bids[bids.length-1];
          $.setFragment({
            "bids": bids.join(','),
            "sids": question,
            "new_level": true,
            "origin": last_bid
          });
          return false;
        });

				/* NEW FOLLOW-UP QUESTION BUTTON (ON CHILDREN)*/
        fuq_children.find("a.create_follow_up_question_button:Event(!click)").bind("click", function() {
          var bids = $('#breadcrumbs').data('api').getBreadcrumbStack($(this));
          $.setFragment({
            "bids": bids.join(','),
            "new_level": true,
						"origin" : bids[bids.length -1]
          });
        });
			}


			function initFUQSiblingsLinks(siblings_block) {

        /* FOLLOW-UP QUESTION SIBLING */
        siblings_block.find("a.statement_link.follow_up_question_link:Event(!click)").bind("click", function() {
          var question = $(this).parent().attr('id').replace(/[^0-9]+/, '');
          var bids = $('#breadcrumbs').data('api').getBreadcrumbStack(null);
          var last_bid = bids[bids.length-1];
          $.setFragment({
            "bids": bids.join(','),
            "sids": question,
            "new_level": false,
            "origin": $.fragment().origin
          });
          return false;
        });

        /* NEW FOLLOW-UP QUESTION BUTTON (ON SIBLINGS)*/
        siblings_block.find("a.create_follow_up_question_button:Event(!click)").bind("click", function() {
          var bids = $('#breadcrumbs').data('api').getBreadcrumbStack(null);
          $.setFragment({
            "bids": bids.join(','),
            "new_level": false,
            "origin" : $.fragment().origin
          });
        });
      }


		  /*
		   * Sets the different links on the statement UI, after the user clicked on them (fragment history handling).
		   */
		  function initStatementLinks() {
				var nodeId = statement.attr('id').replace(/[^0-9]+/, '');

		    statement.find('.header a.statement_link').bind("click", function() {
		      var current_stack = getStatementsStack(this, false);
					var bids = $('#breadcrumbs').data('api').getBreadcrumbStack(null);
					var origin = bids.length == 0 ? '' : bids[bids.length-1];
		      $.setFragment({
		        "sids": current_stack.join(','),
		        "new_level": '',
						"bids": bids.join(','),
						"origin": origin
		      });

          if (current_stack[current_stack.length-1] != nodeId) {
            statement.find('.header .loading').show();
          }

		      return false;
		    });

        statement.find('.children').each(function() {
					initChildrenLinks($(this));
				});
		  }

      function initSiblingsLinks(siblings_block){
	      var bids = $('#breadcrumbs').data('api').getBreadcrumbStack(null);
				var origin = bids.length == 0 ? '' : bids[bids.length-1];

        // Child link
        // Note: this handler is for not follow up question child links only. FUQs have their own handler.
        siblings_block.find('a.statement_link:not(.follow_up_question_link):Event(!click)').bind("click", function() {
          var current_stack = getStatementsStack(this, false);
          $.setFragment({
            "sids": current_stack.join(','),
            "new_level": true,
            "bids": bids.join(','),
            "origin": origin
          });
          return false;
        });

        siblings_block.find('a.add_new_button:not(.create_follow_up_question_button):Event(!click)').bind("click", function() {
          $.setFragment({
            "new_level": false,
            "bids": bids.join(','),
            "origin": origin
          })
        });

	    }

      /* */
			function initChildrenLinks(children_block) {
				var bids = $('#breadcrumbs').data('api').getBreadcrumbStack(null);
        var origin = bids.length == 0 ? '' : bids[bids.length-1];

        // Child link
        // Note: this handler is for not follow up question child link only. FUQs have their own handler.
				children_block.find('a.statement_link:not(.follow_up_question_link):Event(!click)').bind("click", function() {
					var current_stack = getStatementsStack(this, true);
          $.setFragment({
            "sids": current_stack.join(','),
            "new_level": true,
						"bids": bids.join(','),
            "origin": origin
          });
          return false;
        });

        children_block.find('a.add_new_button:not(.create_follow_up_question_button):Event(!click)').bind("click", function(){
          $.setFragment({
            "new_level": true,
						"bids": bids.join(','),
            "origin": origin
          })
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

      // Public API
      $.extend(this,
      {
        reinitialise: function(s)
        {
          s = $.extend({}, s, settings, {'load' : false});
          initialise(s);
        },
        // API Functions
				reinitialiseChildren: function(children_container)
				{
					var children_block = statement.find(children_container);
					initMoreButton(children_block);
          initChildrenLinks(children_block);
          initFUQChildrenLinks(children_block);
				},
        insertContent: function(content){
		      statement.append(content);
					return this;
		    },
				reinitialiseSiblings: function(siblings_container)
        {
          var siblings_block = statement.find(siblings_container);
          initSiblingsLinks(siblings_block);
          initFUQSiblingsLinks(siblings_block);
        },
        insertContent: function(content){
          statement.append(content);
          return this;
        },

		    removeBelow: function(){
		     statement.nextAll().each(function(){
			     /* delete the session data relative to this statement first */
			     $('div#statements').removeData(this.id);
			     $(this).remove();

		     });
				 return this;
		    },
        insert: function() {
		      var element = $('div#statements .statement').eq(settings['level']);
		      if(element.length > 0) {
		        element.replaceWith(statement);
		      }
		      else
		      {
		        hideStatements(settings);
		        $('div#statements').append(statement);
		      }
					return this;
		    },
		    loadAuthors: function (authors, length){
		      authors.insertAfter(statement.find('.summary h2')).animate(toggleParams, settings['animation_speed']);
		      statement.find('#authors_list').jcarousel({
		        scroll: 3,
		        buttonNextHTML: "<div class='next_button'></div>",
		        buttonPrevHTML: "<div class='prev_button'></div>",
		        size: length
		      });
					return this;
		    },
		    insertMore: function (level, type_id) {
		      var element = $('#statements div.statement:eq(' + level + ') ' + type_id + ' .headline');
		      statement.insertAfter(element).animate(toggleParams, settings['animation_speed']);
					return this;
		    },
		    /* Expandable Flow */
		    show: function(){
		      statement.find('.content').animate(toggleParams, settings['animation_speed']);
					return this;
		    },
		    hide: function () {
		      statement.find('.header').removeClass('active').addClass('expandable');
		      statement.find('.content').hide('slow');
		      statement.find('.supporters_label').hide();
					return this;
		    }
      });
	  }

  };

})(jQuery);


