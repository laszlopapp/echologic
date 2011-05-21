(function($) {

  $.fn.statement = function(current_settings) {

    $.fn.statement.defaults = {
      'level' : 0,
			'insertStatement' : true,
			'load' : true,
      'echoableClass' : 'echoable',
      'hide_animation_params' : {
        'height' : 'hide',
        'opacity': 'hide'
      },
      'hide_animation_speed': 500,
      'animation_speed': 300
    };

    // Merging settings with defaults
    var settings = $.extend({}, $.fn.statement.defaults, current_settings);

    return this.each(function() {
			// Creating and binding the statement API
			var elem = $(this), statementApi = elem.data('api');
	    if (statementApi) {
	      statementApi.reinitialise(current_settings);
	    } else {
				statementApi = new Statement(elem);
	      elem.data('api', statementApi);
	    }
		});


    /*************************/
    /* The statement handler */
    /*************************/

    function Statement(statement) {
			var timer;
      var statementDomId = statement.attr('id');
			var statementType = statementDomId.match(/[^add_]\w+[^_\d+]/);
      var statementId = getStatementId(statementDomId);
			var parentStatement, statement_index;

      // Initialize the statement
      initialise();


      // Initializes the statement.
      function initialise() {

        if (settings['load']) {
					insertStatement();

          // Initialise index of the current statement
          statement_index = $('#statements .statement').index(statement);
					parentStatement = statement.prev();

					// Navigation through siblings
	        storeSiblings();
					initNavigationButton(statement.find(".header a.prev"), -1); /* Prev */
	        initNavigationButton(statement.find(".header a.next"),  1); /* Next */
				}

				initExpandables();

        if (isEchoable()) {
          statement.echoable();
        }

        initContentLinks();

        /* Statement Form Helpers */
        if(statement.is('form')) {
					statement.statementForm();
        } else {
					initAddNewButton();
          initMoreButton();
          initAllStatementLinks();
					//initFlicks();
        }
      }


      // Returns true if the statement is echoable.
      function isEchoable() {
        return statement.hasClass(settings['echoableClass']);
      }

			function insertStatement() {
				if (!settings['insertStatement']) {return;}

				var element = $('div#statements .statement').eq(settings['level']);
				hideStatements(settings);
				if(element.length > 0) {
          element.replaceWith(statement);
        }
        else
        {
          $('div#statements').append(statement);
        }
			}

      function initExpandables() {
				statement.find(".expandable:Event(!click)").each(function() {
          var expandableElement = $(this);
					if (expandableElement.hasClass('social_echo_button')) {
						// Social Widget button
            expandableElement.expandable({
              'condition_element': expandableElement.parent().prev(),
							'condition_class': 'supported',
							'animation_params': {
                'opacity': 'toggle'
              }
            });
					}
					else if (expandableElement.hasClass('show_siblings_button')) {
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


      function loadJumpLink(url){
				var anchor_index = url.indexOf("#");
        if (anchor_index != -1) {
          url = url.substring(0, anchor_index);
        }
        var bid = 'jp' + statementId;
        var bids = $.fragment().bids;
        
        bids = (bids && bids.length > 0) ? bids.split(',') : [];
        bids.push(bid);
        return $.queryString(url, {"bids" : bids.join(','), "origin" : bid });
				
			}

      function initContentLinks() {
        statement.find(".statement_content a").each(function() {
          var link = $(this);
          link.attr("target", "_blank");
          var url = link.attr("href");
					
          if (url.substring(0,7) != "http://" && url.substring(0,8) != "https://") {
            url =  "http://" + url;
          }
					if (url.match(/\/statement\/\d+/)) { // if this link goes to another statement, then add a jump bid
						url = loadJumpLink(url);
					}
					
					link.attr('href', url);
        });
      }

		  /*
		   * Collapses all visible statements.
		   */
		  function hideStatements() {
				$('#statements .statement .header').removeClass('active').addClass('expandable');
				$('#statements .statement .header:Event(!click)').expandable();
		    $('#statements .statement .content').animate(settings['hide_animation_params'],
                                                     settings['hide_animation_speed']);
		    $('#statements .statement .header .supporters_label').animate(settings['hide_animation_params'],
                                                                      settings['hide_animation_speed']);
		  }

		  /*
		   * Gets the siblings of the statement and places them in the client for navigation.
		   */
		  function storeSiblings() {
        var key;
				if (statement_index > 0) {
		      // Store siblings with the parent node id
					var index = statement_index-1;
					key = $('#statements .statement:eq(' + index + ')').attr('id');
		    } else {
		      // No parent means it's a root node, therefore, store siblings under the key 'roots'
		      key = 'roots';
		    }
		    var siblings = eval(statement.data("siblings"));
		    if (siblings != null) {
		      $("#statements").data(key, siblings);
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
				var currentStatementId = button.attr('data-id');
		    if (currentStatementId.match('add')) {
		      var idParts = currentStatementId.split('_');
		      currentStatementId = [];
		      // Get parent id
          if(idParts[0].match(/\d+/)) {
            currentStatementId.push(idParts.shift());
          }
		      // Get 'add'
          currentStatementId.push(idParts.shift());
		      currentStatementId.push(idParts.join('_'));
          currentStatementId = "/"+currentStatementId.join('/');
		    } else {
          currentStatementId = eval(currentStatementId);
        }

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
				var targetIndex = ($.inArray(currentStatementId,siblingIds) + inc + siblingIds.length) % siblingIds.length;
		    var targetStatementId = new String(siblingIds[targetIndex]);
				if (targetStatementId.match('add')) {
          // Add (teaser) link
					button.attr('href', button.attr('href').replace(/statement\/.*/, 'statement/' + targetStatementId));
		    }
		    else {
					button.attr('href', button.attr('href').replace(/statement\/.*/, "statement/" + targetStatementId));
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
		   * Handles the click on the more Button event (replaces it with an element of class 'more_loading')
		   */
		  function initMoreButton() {
		    statement.find(".more_pagination a:Event(!click)").bind("click", function() {
          var moreButton = $(this);
					moreButton.replaceWith($('<span/>').text(moreButton.text()).addClass('more_loading'));
		    });
		  }

      /*
       * Sets the different links on the statement UI, after the user clicked on them.
       */
      function initFlicks(){
	     statement.detectFlicks({
         axis: 'y',
         threshold: 15,
         flickEvent: function(d) 
				 { 
				   alert('flick detected: ' + d.direction);
					 var button = null;
					 switch(d.direction) {
					 	case 'left2right' :
						  button = statement.find('.header a.next');
						  break;
					  case 'right2left' :
						  button = statement.find('.header a.prev');
						  break;
					 }
					 if (button) {
					 	button.addClass('clicked');
						button.click();
					 }
         }
        });
	    }

      function generateBreadcrumbKey() {
				if (parentStatement.length > 0) {
          return generateKey(statementType) + getStatementId(parentStatement.attr('id'));
        } else {
          return $.fragment().origin;
        }
			}
			
		  /*
		   * Sets the different links on the statement UI, after the user clicked on them.
		   */
		  function initAllStatementLinks() {
				var key = generateBreadcrumbKey();
				
        statement.find('.header a.statement_link').bind("click", function() {
					
					var old_stack = $.fragment().sids;
		      var current_stack = getStatementsStack(this, false);
					var current_bids = $('#breadcrumbs').data('breadcrumbApi').getBreadcrumbStack(null);
					var bids = current_bids;
					
					// Update the bids
					var index = $.inArray(key, bids);
					if (index != -1) { // if parent breadcrumb exists, then delete everything after it
						bids = bids.splice(0, index + 1);
					}
					// save element after which the breadcrumbs will be deleted
          $('#breadcrumbs').data('element_clicked', key);
					
					var origin = $.fragment().origin;

					if (current_stack.join(',') != old_stack) {
            statement.find('.header .loading').show();
          }

		      $.setFragment({
		        "sids": current_stack.join(','),
		        "new_level": '',
						"bids": bids.join(','),
						"origin": origin
		      });

		      return false;
		    });

        statement.find('.children').each(function() {
					initChildrenLinks($(this));
				});
		  }

      /*
       * Initializes links for all statements but Follow-up Questions.
       * new_level = false
       */
      function initSiblingsLinks(container) {
        initStatementLinks(container, false)
	    }

      /*
       * Initializes links for all statements but Follow-up Questions.
       * new_level = true
       */
			function initChildrenLinks(container) {
        initStatementLinks(container, true)
			}

      /*
       * Initializes links for all statements but Follow-up Questions.
       */
      function initStatementLinks(container, newLevel) {
				var current_stack = getStatementsStack(null, newLevel);
				
				container.find('a.statement_link').bind("click", function() {
					var childId = $(this).parent().attr('statement-id');
					var key = generateKey($(this).parent().attr('class'));
					var current_bids = $('#breadcrumbs').data('breadcrumbApi').getBreadcrumbStack(null);
					
					var bids = current_bids;
          if(newLevel){ // necessary evil: erase all breadcrumbs after the parent of the clicked statement
            var or_index = bids.length == 0 ? 0 : $.inArray($.fragment().origin, bids);
            var level = or_index + (statement_index+1);
            bids = bids.splice(0, level);
            var new_bid = key + statementId;
            bids.push(new_bid);
          } 
					else { // siblings box or maybe alternatives box
						var parentKey = generateBreadcrumbKey();
						var index = $.inArray(parentKey, bids);
	          if (index != -1) { // if parent breadcrumb exists, then delete everything after it
	            bids = bids.splice(0, index + 1);
	          }
					}
					
					var stack = current_stack, origin;
          switch(key){
						case 'fq':
						  stack = [childId];
							origin = bids.length == 0 ? '' : bids[bids.length - 1];
						  break;
						default :
						  stack.push(childId);
							origin = $.fragment().origin;
						  break;
					}
					
					
          
          $('#breadcrumbs').data('element_clicked', generateBreadcrumbKey());
					
          $.setFragment({
            "sids": stack.join(','),
            "new_level": newLevel,
						"bids": bids.join(','),
						"origin": origin
          });
          return false;
        });
      }
			
			

      


		  /*
		   * Returns an array of statement ids that should be loaded to the stack after 'statementLink' was clicked
		   * (and a new statement is loaded).
		   * - statementLink: HTML element that was clicked
		   * - newLevel: true or false (child statement link)
		   */
		  function getStatementsStack(statementLink, newLevel) {
				if (statementLink) {
					// Get soon to be visible statement
					var path = statementLink.href.split("/");
					var id = path.pop().split('?').shift();
					
					var current_sids;
					if (id.match(/\d+/)) {
						current_sids = id;
					}
					else {
						// Add teaser case
						// When there's a parent id attached, copy :id/add/:type, or else, just copy the add/:type
						var index_backwards = path[path.length - 2].match(/\d+/) ? 2 : 1;
						current_sids = path.splice(path.length - index_backwards, 2);
						current_sids.push(id);
						current_sids = current_sids.join('/');
					}
		    }
				
		    // Get current_stack of visible statements (if any matches the clicked statement, then break)
				var current_stack = [];
		    $("#statements .statement").each( function(index){
		      if (index < statement_index) {
		        id = $(this).attr('id').split('_').pop();
		        if(id.match("add")){
		          id = "add/" + id;
		        }
		        current_stack.push(id);
		      } else if (index == statement_index) {
		         if (newLevel) {
		          current_stack.push($(this).attr('id').split('_').pop());
		         }
		        }
		    });
		    // Insert clicked statement
				if (current_sids) {
					current_stack.push(current_sids);
				}
				return current_stack;
		  }

      // Public API of statement
      $.extend(this,
      {
        reinitialise: function(resettings)
        {
          settings = $.extend({}, resettings, settings, {'load' : false});
          initialise();
        },

				reinitialiseChildren: function(childrenContainerSelector) {
					var container = statement.find(childrenContainerSelector);
					initMoreButton();
          initChildrenLinks(container);
					if (isEchoable) {
            statement.data('echoableApi').loadRatioBars(container);
          }
				},

				reinitialiseSiblings: function(siblingsContainerSelector) {
          var container = statement.find(siblingsContainerSelector);
          initSiblingsLinks(container);
					if (isEchoable) {
			  		statement.data('echoableApi').loadRatioBars(container);
				  }
        },

        insertContent: function(content) {
          statement.append(content);
          return this;
        },

		    removeBelow: function(){
		     statement.nextAll().each(function() {
			     // Delete the session data relative to this statement first
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
		        hideStatements();
		        $('div#statements').append(statement);
		      }
					return this;
		    },

		    loadAuthors: function (authors) {
		      authors.insertAfter(statement.find('.summary h2')).animate(toggleParams, settings['animation_speed']);
					var length = authors.find('.author').length;
		      statement.find('.authors_list').jcarousel({
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
		    show: function() {
		      statement.find('.content').animate(toggleParams, settings['animation_speed']);
					return this;
		    },

		    hide: function () {
		      statement.find('.header').removeClass('active').addClass('expandable');
		      statement.find('.content').hide('slow');
		      statement.find('.supporters_label').hide();
					return this;
		    },
        loadRatioBars: function(container) 
        {
          initRatioBars(container);
        }
      });
	  }

  };

})(jQuery);


