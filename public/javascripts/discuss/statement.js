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
			var elem = $(this);
      var statementApi = elem.data('api');
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
      var statementDomId = statement.attr('id');
			var statementDomParent = statement.attr('dom-parent');
			var statementType = statement.attr('id').match("new") ? $.trim(statement.find('input#type').val()) :
                                                              $.trim(statementDomId.match(/[^(add_|new_)]\w+[^_\d+]/));
      var statementId = getStatementId(statementDomId);
			var parentStatement, statement_index;
			var statementUrl;
			var embedPlaceholder = statement.find('.embed_placeholder');

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
        initChildrenTabbars();

        if (isEchoable()) {
          statement.echoable();
        }

        initContentLinks();

        /* Statement Form Helpers */
        if(statement.is('form')) {
					statement.statementForm();
        } else {
					statementUrl = statement.find('.header_link a.statement_link').attr('href');

					initAddNewButton();
					initClipboardButton();
          initMoreButton();
          initAllStatementLinks();
					if(embedPlaceholder.length > 0) {
						initEmbeddedContent();
					}
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
					if (statementDomId.match('new') && element.data('api').getType() != statementType) {
						var dom_parent = statementDomParent;
						if (dom_parent && dom_parent.length > 0) {
							var key = $.inArray(dom_parent.substring(0,2),['ds','sr']) == -1 ?
							          $("#statements div#" + dom_parent).data('api').getBreadcrumbKey() :
												dom_parent.substring(0,2);
							var parentBreadcrumb = $("#breadcrumbs").data('breadcrumbApi').getBreadcrumb(key);
							if (parentBreadcrumb.length > 0) {
								parentBreadcrumb.nextAll().remove();
							}
						}
						else {
							element.data('api').deleteBreadcrumb();
						}
				  }
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


			/*
       * Handles the children tabs and their content panels.
       */
      function initChildrenTabbars() {
				statement.find(".children").each(function(){
					var container = $(this);
					var tabbar = container.find('.headline');
					var loading = tabbar.find('.loading');
					var childrenContent = container.find('.children_content');

				  container.find("a.child_header").bind('click', function(){
						var oldTab = container.find('a.child_header.selected');
						var newTab = $(this);
            var oldChildrenPanel = childrenContent.find('div.' + oldTab.attr('type'));
						var newChildrenPanel = childrenContent.find('div.' + newTab.attr('type'));

            // Switching tabs
            var tabbarVisible = childrenContent.is(":visible");
            if (newChildrenPanel.length > 0) {
							if (!newChildrenPanel.is(':visible')) {
                switchTabs(oldTab, newTab, childrenContent, oldChildrenPanel, newChildrenPanel, tabbarVisible);
              }
						} else {
							var path = newTab.attr('href');
							loading.show();
							$.ajax({
				        url:      path,
				        type:     'get',
				        dataType: 'script',
								success: function(data, status) {
									newChildrenPanel = childrenContent.find('.children_container:first');
									if (!newChildrenPanel.is(':visible')) {
		                switchTabs(oldTab, newTab, childrenContent, oldChildrenPanel, newChildrenPanel, tabbarVisible);
										loading.hide();
		              }
								},
								error: function() {
									loading.hide();
								}
				      });
						}
            // Expanding the content if the headline is closed
            if (!tabbarVisible) { tabbar.data('expandableApi').toggle(); }
						return false;
					});
				});
			}

      function switchTabs(oldTab, newTab, childrenContent, oldChildrenPanel, newChildrenPanel, animate) {
        oldTab.removeClass('selected');
        newTab.addClass('selected');
        oldChildrenPanel.hide();
        if (animate) {
          newChildrenPanel.fadeIn(settings['animation_speed']);
          childrenContent.height(oldChildrenPanel.height()).
            animate({'height': newChildrenPanel.height()}, settings['animation_speed'], function() {
              childrenContent.removeAttr('style');
            });
        } else {
          newChildrenPanel.show();
        }
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
				$('#statements .statement .header:Event(!click)').expandable();
				$('#statements .statement .header').removeClass('active').addClass('expandable');
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
					button.attr('href', button.attr('href').replace(/statement\/.*/, "statement" + targetStatementId));
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

	    function initClipboardButton() {
				var statement_url = statement.find('.action_bar .statement_url');
				statement.find('.action_bar a.copy_url_button').bind("click", function() {
          $(this).next().animate({'opacity' : 'toggle'}, settings['animation_speed']);
					statement_url.show().select();
          return false;
        });
				statement.find('.action_bar .copy_url_panel').bind("mouseleave", function() {
          $(this).fadeOut();
          return false;
        });
			}

		  /*
		   * Handles the click on the more Button event (replaces it with an element of class 'more_loading')
		   */
		  function initMoreButton() {
				initContainerMoreButton(statement);
		  }

			function initContainerMoreButton(container) {
				container.find(".more_pagination a:Event(!click)").bind("click", function() {
          var moreButton = $(this);
					var moreLoading = $('<span/>').text(moreButton.text()).addClass('more_loading');
					moreButton.hide();
					moreLoading.insertAfter(moreButton);
          var path = moreButton.attr('href');
					$.ajax({
				  	url: path,
				  	type: 'get',
				  	dataType: 'script',
				  	success: function(data, status){
							moreButton.remove();
				  	},
				  	error: function(){
				  	 moreLoading.remove();
						 moreButton.show();
				  	}
				  });
					return false;
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
        statement.find('.header a.statement_link').bind("click", function() {
					var key = generateBreadcrumbKey();

					var old_stack = $.fragment().sids;
		      var current_stack = getStatementsStack(this, false);
					var current_bids = $('#breadcrumbs').data('breadcrumbApi').getBreadcrumbStack(null);
					var bids = current_bids;

					// Update the bids
					var index = $.inArray(key, bids);
					if (index != -1) { // if parent breadcrumb exists, then delete everything after it
						bids = bids.splice(0, index + 1);
					} else { // if parent breadcrumb doesn't exist, it means top stack statement
						bids = bids.splice(0, current_bids.length - current_bids.length%3);
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

	      statement.find('.alternatives').each(function(){
					initSiblingsLinks($(this));
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


			function reinitialiseChildren(childrenContainerSelector) {
				var container = statement.find(childrenContainerSelector);
        initContainerMoreButton(container);
        initChildrenLinks(container);
        if (isEchoable) {
          statement.data('echoableApi').loadRatioBars(container);
        }
			}

			function reinitialiseSiblings(siblingsContainerSelector) {
	      var container = statement.find(siblingsContainerSelector);
        initContainerMoreButton(container);
        initSiblingsLinks(container);
        if (isEchoable) {
          statement.data('echoableApi').loadRatioBars(container);
        }
	    }


			/********************/
			/* EMBEDDED CONTENT */
			/********************/

			function initEmbeddedContent() {
		  	embedPlaceholder.embedly({
          maxWidth: 990,
          maxHeight: 1000,
          className: 'embedded_content',
          success: embedlySuccess,
					error: embedlyError
		  	});
		  }

      function embedlySuccess(oembed, dict) {
        var elem = $(dict.node);
        if (! (oembed) ) { return null; }
        elem.replaceWith(oembed.code);
        showEmbeddedContent(oembed.type != 'video');
      }

      function embedlyError(node, dict) {
        node.replaceWith($("<div/>").addClass('embedded_content').addClass('manual')
                          .append($("<iframe/>").attr('frameborder',0).attr('src', node.attr('href'))));
        showEmbeddedContent(true);
      }

      function showEmbeddedContent(animate) {
        setTimeout(function() {
          statement.find('.embed_container .loading').hide();
          if (animate) {
            statement.find('.embedded_content').animate(toggleParams, 700);
          } else {
            statement.find('.embedded_content').fadeIn(700);
          }
        }, 2000);
      }


      // Public API of statement
      $.extend(this,
      {
        reinitialise: function(resettings)
        {
          settings = $.extend({}, resettings, settings, {'load' : false});
          initialise();
        },

        reinitialiseContainerBlock: function(containerSelector, newLevel) {
					newLevel ? reinitialiseChildren(containerSelector) : reinitialiseSiblings(containerSelector);
				},

				reinitialiseChildren: function(childrenContainerSelector) {
					reinitialiseChildren(siblingsContainerSelector);
				},

				reinitialiseSiblings: function(siblingsContainerSelector) {
          reinitialiseSiblings(siblingsContainerSelector);
        },

        insertContent: function(content) {
          statement.append(content);
          return this;
        },

		    removeBelow: function(){
		     statement.nextAll().each(function() {
			     // Delete the session data relative to this statement first
					 /*if (statementDomId.match('new')) {
				   	$(this).data('api').deleteBreadcrumb();
				   }*/
			     $('div#statements').removeData(this.id);
			     $(this).remove();

		     });
				 return this;
		    },
				getBreadcrumbKey: function() {
					return generateBreadcrumbKey();
				},
				deleteBreadcrumb: function() {
					var key = generateBreadcrumbKey();
				  $('#breadcrumbs').data('breadcrumbApi').deleteBreadcrumb(key);
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
          statement.data('echoableApi').loadRatioBars(container);
					return this;
        },
				getType: function()
				{
					return statementType;
				}
      });
	  }

  };

})(jQuery);


