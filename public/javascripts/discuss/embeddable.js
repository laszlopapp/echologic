(function($){

  $.fn.embeddable = function() {


    // Merging settings with defaults
    var settings = {
			'video_settings' : {
        'width' : 640,
        'height': 390
      }
    };

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


    /*******************/
    /* The Alternative */
    /*******************/

    function Embeddable(embeddable) {
			var node_info = embeddable.find('.info_types_container');
			var embed_url = embeddable.find('input.embed_url');
      var embedded_content = embeddable.find('.embedded_content');
      var selected_content_type, change_event;
			
			
      initialize();

      /*
       * Initializes an embeddable.
       */
      function initialize() {
				node_info.jqTransform();
        handleInputTypeClicks();
        handleInputURL();
      }
      
			/*
       * Handles the click events on the background info type labels
       */
      function handleInputTypeClicks() {
        var content_type_labels = node_info.find('ol li label');
        var content_type_radios = node_info.find("ol li input[type='radio']");
        content_type_labels.each(function(){
          loadInputType($(this));
        }); 
        content_type_labels.bind('click', function(){
					var previous_selected_content_type = selected_content_type;       
          deselectContentType();
          selectContentType($(this));
					if(previous_selected_content_type != selected_content_type){triggerChange();}
        });
        content_type_radios.bind('click', function(){
					var previous_selected_content_type = selected_content_type;
          deselectContentType();
          selectContentType($(this).parent().siblings('label'));
					if(previous_selected_content_type != selected_content_type){triggerChange();}
        });
      }
			
			function triggerChange() {
				if(change_event) {
          embeddable.trigger(change_event);
        }
			}

      function loadInputType(label) {
        if (label.siblings().find('a.jqTransformRadio').hasClass('jqTransformChecked')) {
          label.addClass('selected');
          selected_content_type = label;
        }
      }
      
      function selectContentType(label) { 
        label.addClass('selected').find('a.jqTransformRadio').addClass('jqTransformChecked');
        selected_content_type = label;
      }
      
      function deselectContentType() {
        if (selected_content_type) { selected_content_type.removeClass('selected').find('a.jqTransformRadio').removeClass('jqTransformChecked'); }
      }
      

      /*
       * Handles the event of filling the info url (triggers the loading of that url on an iframe)
       */
      function handleInputURL() {
        var url_value = embed_url.val();
        if (url_value && url_value.length > 0) {
          loadEmbeddedContent(url_value);
        }
        embed_url.bind('change', function(){
          if (url_value != embed_url.val())
          {
            url_value = embed_url.val();  
            loadEmbeddedContent(url_value);
						triggerChange();
          }
        });
      }
      
      /*
       * Loads an url onto the iframe
       */
      function loadEmbeddedContent(url) {
        var handled_url = url;
        if (containsYoutubeVideo(handled_url)){
          handled_url = getYoutubeEmbeddedCode(handled_url);
          embedded_content.attr('width', settings['video_settings']['width']).attr('height', settings['video_settings']['height']);
          embedded_content.attr('allowfullscreen',''); 
        } else if (containsVimeoVideo(handled_url)) {
          handled_url = getVimeoEmbeddedCode(handled_url);
          embedded_content.attr('width', settings['video_settings']['width']).attr('height', settings['video_settings']['height']);
        } else {
          embedded_content.removeAttr('width').removeAttr('height');
          embedded_content.removeAttr('allowfullscreen');
        }
        embedded_content.attr('src',handled_url);
        if (!embedded_content.is(':visible')) {
          embedded_content.fadeIn();
        }       
      }
      
      /* 
       * checks if the url is from a video (youtube)
       */
      function containsYoutubeVideo(url) {
        return url.match(/.*http:\/\/(\w+\.)?youtube.com\/watch\?v=(\w+).*/);
      }
      
      /* 
       * checks if the url is from a video (vimeo)
       */
      function containsVimeoVideo(url) {
        return url.match(/.*http:\/\/(\w+\.)?vimeo.com\/(\d+).*/);
      }
      
      function getYoutubeEmbeddedCode(url) {
        var video_id = url.match("[\?&]v=([^&#]*)")[1];
        return "http://www.youtube.com/embed/" + video_id;
      }
      
      function getVimeoEmbeddedCode(url) {
        var video_id = url.match("vimeo\.com/(?:.*#|.*/videos/)?([0-9]+)")[1];
        return "http://player.vimeo.com/video/" + video_id + "?portrait=0";
      }
			
			function handleEmbeddedContentChange(eventName) {
				change_event = eventName;
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
          selectContentType(node_info.find('a.' + content_type).parent().siblings('label'));
          
          embed_url.val(external_url);
					loadEmbeddedContent(external_url);
          embedded_content.fadeIn();
				},
				unlinkEmbeddedContent: function() {
					deselectContentType();
          embed_url.val('');
					loadEmbeddedContent(external_url);
          embedded_content.hide();
				},
				handleContentChange: function(eventName) {
					handleEmbeddedContentChange(eventName);
				}
      });
    }

  };

})(jQuery);
