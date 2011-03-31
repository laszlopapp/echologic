(function($, window, undefined){

  $.fn.taggable = function(settings) {

    function Taggable(taggable){

			initialise();

			function initialise(){
			  loadTags();
				loadTagEvents();
				loadStatementAutoComplete();
			}

			// Auxiliary Functions

			/*
       * load this current statement's already existing tags into the tags input box
       */
      function loadTags() {
        var tags_to_load = taggable.find('input.question_tags').val();
        tags_to_load = $.trim(tags_to_load);
        tags_to_load = tags_to_load.split(',');
				while (tags_to_load.length > 0) {
          var tag = $.trim(tags_to_load.shift());
          if (tag.localeCompare(' ') > 0) {
            var element = createTagButton(tag, ".question_tags");
            taggable.find('#question_tags_values').append(element);
          }
        }
      }

			/*
       * adds event handling to all the possible interactions with the tags box
       */
      function loadTagEvents() {
        /* Pressing 'enter' button */
        taggable.find('#tag_topic_id').bind('keypress', (function(event) {
          if (event && event.keyCode == 13) { /* check if enter was pressed */
            if (taggable.find('#tag_topic_id').val().length != 0) {
              taggable.find('.addTag').click();
            }
            return false;
          }
        }));

        /* Clicking 'add tag' button */
        taggable.find('.addTag').bind('click', (function() {
          var entered_tags = taggable.find('#tag_topic_id').val().trim().split(",");
          if (entered_tags.length != 0) {
            /* Trimming all tags */
            entered_tags = jQuery.map(entered_tags, function(tag) {
              return (tag.trim());
            });
            var existing_tags = taggable.find('.question_tags').val();
            existing_tags = existing_tags.split(',');
            existing_tags = $.map(existing_tags,function(q){return q.trim()});

            var new_tags = new Array(0);
            while (entered_tags.length > 0) {
              var tag = entered_tags.shift().trim();
              if ($.inArray(tag,existing_tags) < 0 && $.inArray(tag,entered_tags) < 0) {
                if (tag.localeCompare(' ') > 0) {
                  var element = createTagButton(tag, ".question_tags");
                  $('#question_tags_values').append(element);
                  new_tags.push(tag);
                }
              }
            }
						var question_tags = taggable.find('.question_tags').val();
						if (new_tags.length > 0) {
              question_tags = ((question_tags.trim().length > 0) ? question_tags + ',' : '') + new_tags.join(',');
              taggable.find('.question_tags').val(question_tags);
            }
						taggable.find('#tag_topic_id').val('');
            taggable.find('#tag_topic_id').focus();
          }
        }));
      }

			/*
       * Aux: Creates the statement tag HTML Element
       * text: tag text ; tags_class: css class of the tags hidden input container
       */
      function createTagButton(text, tags_class) {
        var element = $('<span/>').addClass('tag');
        element.text(text);
        var deleteButton = $('<span class="delete_tag_button"></span>');
        deleteButton.click(function(){
          $(this).parent().remove();
          var tag_to_delete = $(this).parent().text();
					var form_tags = taggable.find(tags_class).val();
					form_tags = form_tags.split(',');
          form_tags = $.map(form_tags,function(q){return q.trim()});
          var index_to_delete = $.inArray(tag_to_delete,form_tags);
          if (index_to_delete >= 0) {
            form_tags.splice(index_to_delete, 1);
          }
          taggable.find(tags_class).val(form_tags.join(','));
        });
        element.append(deleteButton);
        return element;
      }

			/*
       * Initializes auto_complete property for the tags text input
       */
      function loadStatementAutoComplete() {
        taggable.find('.tag_value_autocomplete').autocomplete('../../discuss/auto_complete_for_tag_value',
                                                              {minChars: 3, selectFirst: false, multiple: true});
      }


		  // API Functions

		  $.extend(this,
      {
				reinitialise: function()
        {
          initialise();
        }
			});
		}

    $.fn.taggable.defaults = {
      'animation_speed': 500
    };

    // Pluginifying code...
    var settings = $.extend({}, $.fn.taggable.defaults, settings);

    return this.each(function() {
	    var elem = $(this), taggableApi = elem.data('taggableApi');
	    if (taggableApi) {
	      taggableApi.reinitialise();
	    } else {
	    taggableApi = new Taggable(elem);
	      elem.data('taggableApi', taggableApi);
	    }
    });
  };
})(jQuery,this);