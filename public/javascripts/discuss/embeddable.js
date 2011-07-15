
(function($){

  $.fn.embeddable = function(current_settings) {

    $.fn.embeddable.defaults = {
      'embed_speed': 500,
      'scroll_speed': 300,
      'embed_delay': 2000
    };

    // Merging settings with defaults
    var settings = $.extend({}, $.fn.embeddable.defaults, current_settings);

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
      var selectedType, changeEvent;

      initialize();


      /*
       * Initializes an embeddable.
       */
      function initialize() {
				entryTypes.jqTransform();
        initEntryTypes();
        initEmbedURL();
      }

			/*
       * Handles the click events on the background info type labels.
       */
      function initEntryTypes() {
        var entryTypeLabels = entryTypes.find("li label");
        var entryTypeRadios = entryTypes.find("li input[type='radio']");
        entryTypeLabels.each(function(){
          loadType($(this));
        });
        var previousType = selectedType;
        entryTypeLabels.bind('click', function(){
          deselectType();
          selectType($(this));
					if(previousType != selectedType) {triggerChangeEvent();}
        });
        entryTypeRadios.bind('click', function(){
          deselectType();
          selectType($(this).parent().siblings('label'));
					if(previousType != selectedType) {triggerChangeEvent();}
        });
      }

      /*
       * Triggers the unlink event on type change.
       */
      function triggerChangeEvent() {
				if(changeEvent) {
          embeddable.trigger(changeEvent);
        }
			}

      function loadType(label) {
        if (label.siblings().find('a.jqTransformRadio').hasClass('jqTransformChecked')) {
          label.addClass('selected');
          selectedType = label;
        }
      }

      function selectType(label) {
        label.addClass('selected').find('a.jqTransformRadio').addClass('jqTransformChecked');
        selectedType = label;
				embedUrl.removeAttr('disabled');
      }

      function deselectType() {
        if (selectedType) {
          selectedType.removeClass('selected').find('a.jqTransformRadio').removeClass('jqTransformChecked');
        }
      }


      /*
       * Initiates the event of filling the info url (triggers the loading of that url on an iframe)
       */
      function initEmbedURL() {

        // URL Input
				if (!selectedType) {
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
          triggerChangeEvent();
        });

        // Preview button
				embedData.find('.preview_button').bind('click', function(){
					showEmbedPreview();
					return false;
				});

        // Submit button
				embeddable.bind('submit', function(){
					var url = embedUrl.val();
					if (!url.match(/http(s)?:\/\/.*/)) {embedUrl.val("http://" + url);}
				});
      }


			function showEmbedPreview() {
				var url = embedUrl.val();
				if (!url.match(/http(s)?:\/\/.*/)) {url = "http://" + url;}
				if (isValidUrl(url)) {
          if (!embedPreview.is(':visible')) {
				    embedPreview.animate(toggleParams, settings['embed_speed']);
            scrollToPreview();
          }
          loadEmbeddedContent(url);
				} else {
					error(embedUrl.data('invalid-message'));
				}
			}

      /*
       * Loads embedded content with the given URL.
       */
      function loadEmbeddedContent(url) {

        // Reseting the preview area
        var embeddedContent = embedPreview.find('.embedded_content');
        if (embeddedContent.is(':visible')) {
          embedPreview.find('.embedded_content').animate(toggleParams, settings['embed_speed'], function() {
            embeddedContent.remove();
            scrollToPreview();
          });
        }
        embedCommand.attr('href', url);

        // Embed URL
        embedPreview.find('.loading').show();
				embedCommand.embedly({
          maxWidth: 990,
          maxHeight: 1000,
          className: 'embedded_content',
          success: embedlyEmbed,
					error: manualEmbed
		  	});
      }

      function embedlyEmbed(oembed, dict) {
        var elem = $(dict.node);
        if (! (oembed) ) { return null; }
        if (oembed.type != 'link') {
          elem.after(oembed.code);
          showEmbeddedContent();
        } else {
          manualEmbed(elem, null);
        }
      }

      function manualEmbed(node, dict) {
        node.after($("<div/>").addClass('embedded_content').addClass('manual')
                    .append($("<iframe/>").attr('frameborder', 0).attr('src', node.attr('href'))));
        showEmbeddedContent();
      }

      function showEmbeddedContent() {
        setTimeout(function() {
          embedPreview.find('.loading').hide();
          embedPreview.find('.embedded_content').fadeIn(settings['embed_speed'], scrollToPreview);
        }, settings['embed_delay']);
      }

      function scrollToPreview() {
        $.scrollTo('form.embeddable .entry_url_container', settings['scroll_speed']);
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

					deselectType();
          selectType(entryTypes.find('a.' + content_type).parent().siblings('label'));
          embedUrl.val(external_url);
					loadEmbeddedContent(external_url);
				},

				unlinkEmbeddedContent: function() {
				},

				handleContentChange: function(eventName) {
					changeEvent = eventName;
				}
      });
    }

  };

})(jQuery);
