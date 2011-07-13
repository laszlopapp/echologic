
(function($){

  $.fn.embeddable = function() {

    return this.each(function() {
      /* Creating embeddable and binding its API */
      var elem = $(this), embeddableApi = elem.data('embeddableApi');
      if (embeddableApi) {
        embeddableApi.reinitialize();
      } else {
        embeddableApi = new Embeddable(elem);
        elem.data('embeddableApi', embeddableApi);
      }
    });


    /******************/
    /* The Embeddable */
    /******************/

    function Embeddable(embeddable) {

			var embedData = embeddable.find('.embed_data');
			var entryTypes = embedData.find('.entry_types');
			var embedUrl = embedData.find('input.embed_url');

      var embedPreview = embeddable.find('.embed_preview');
      var embedCommand = embedPreview.find('.embed_command');
      var selectedContentType, changeEvent;

      initialize();


      /*
       * Initializes an embeddable.
       */
      function initialize() {
				entryTypes.jqTransform();
        handleEntryTypeClicks();
        handleInputURL();
				handleEmbeddedContent();
      }

			/*
       * Handles the click events on the background info type labels.
       */
      function handleEntryTypeClicks() {
        var entryTypeLabels = entryTypes.find("li label");
        var entryTypeRadios = entryTypes.find("li input[type='radio']");
        entryTypeLabels.each(function(){
          loadInputType($(this));
        });
        var previousContentType = selectedContentType;
        entryTypeLabels.bind('click', function(){
          deselectContentType();
          selectContentType($(this));
					if(previousContentType != selectedContentType) {triggerChange();}
        });
        entryTypeRadios.bind('click', function(){
          deselectContentType();
          selectContentType($(this).parent().siblings('label'));
					if(previousContentType != selectedContentType) {triggerChange();}
        });
      }

			function triggerChange() {
				if(changeEvent) {
          embeddable.trigger(changeEvent);
        }
			}

      function loadInputType(label) {
        if (label.siblings().find('a.jqTransformRadio').hasClass('jqTransformChecked')) {
          label.addClass('selected');
          selectedContentType = label;
        }
      }

      function selectContentType(label) {
        label.addClass('selected').find('a.jqTransformRadio').addClass('jqTransformChecked');
        selectedContentType = label;
				embedUrl.removeAttr('disabled');
      }

      function deselectContentType() {
        if (selectedContentType) {
          selectedContentType.removeClass('selected').find('a.jqTransformRadio').removeClass('jqTransformChecked');
        }
      }

      /*
       * Handles the event of filling the info url (triggers the loading of that url on an iframe)
       */
      function handleInputURL() {
				if (!selectedContentType) {
					embedUrl.attr('disabled', 'disabled');
				}
				var invalid_message = embedUrl.attr('invalid-message');
				embedUrl.data('invalid-message', invalid_message);
				embedUrl.removeAttr('invalid-message');
				embedUrl.bind('keypress', function (event) {
					if (event && event.keyCode == 13) { /* check if enter was pressed */
					  showEmbedPreview();
						return false;
					}
        });
				handlePreviewButton();
				embeddable.bind('submit', function(){
					var url = embedUrl.val();
					if (!url.match(/http(s)?:\/\/.*/)) {embedUrl.val("http://" + url);}
				});
      }

			function handlePreviewButton() {
				embedUrl.next().bind('click', function(){
					showEmbedPreview();
					return false;
				});
			}

			function showEmbedPreview() {
				var url = embedUrl.val();
				if (!url.match(/http(s)?:\/\/.*/)) {url = "http://" + url;}
				if (isValidUrl(url)) {
					embedData.hide();
				  loadEmbeddedContent(url);
					embedPreview.show();
					triggerChange();
				} else {
					error(embedUrl.data('invalid-message'));
				}
			}


			function handleEmbeddedContent() {
				embedPreview.hide();
				embedPreview.find('.embedded_content_button').bind('click', function() {
					showEmbedData();
					return false;
				});
			}

      function showEmbedData() {
				embedPreview.hide();
				embedData.show();
			}


      /*
       * Loads embedded content with the given URL.
       */
      function loadEmbeddedContent(url) {
        // Reset command
				embedCommand.nextAll().remove();
        embedCommand.attr('href', url);
        // Embed URL
				embedCommand.embedly({
          maxWidth: 990,
          maxHeight: 1000,
          className: 'embedded_content',
          success: embedlySuccess,
					error: embedlyError
		  	});
        embedPreview.find('.loading').show();
      }

      function embedlySuccess(oembed, dict) {
        var elem = $(dict.node);
        if (! (oembed) ) { return null; }
        elem.after(oembed.code);
        showEmbeddedContent(oembed.type != 'video');
      }

      function embedlyError(node, dict) {
        node.after($("<div/>").addClass('embedded_content').addClass('manual')
                     .append($("<iframe/>").attr('frameborder',0).attr('src', node.attr('href'))));
        showEmbeddedContent(true);
      }

      function showEmbeddedContent(animate) {
        setTimeout(function() {
          embedPreview.find('.loading').hide();
          if (animate) {
            embedPreview.find('.embedded_content').animate(toggleParams, 700);
          } else {
            embedPreview.find('.embedded_content').fadeIn(700);
          }
        }, 2000);
      }


     	function handleEmbeddedContentChange(eventName) {
				changeEvent = eventName;
			}

			function isValidUrl(url) {
				return url.match(/^(http|https|ftp):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/i);
			}


      // Public API
      $.extend(this,
      {
        reinitialize: function() {
          initialize();
        },

				linkEmbeddedContent: function(data) {
					var content_type = data['content_type'];
          var external_url = data['external_url'];

					deselectContentType();
          selectContentType(entryTypes.find('a.' + content_type).parent().siblings('label'));
          embedUrl.val(external_url);
					loadEmbeddedContent(external_url);
				},

				unlinkEmbeddedContent: function() {
//					deselectContentType();
//          embedUrl.val('');
//					loadEmbeddedContent(external_url);
//          embeddedContent.hide();
				},

				handleContentChange: function(eventName) {
					handleEmbeddedContentChange(eventName);
				}
      });
    }

  };

})(jQuery);
