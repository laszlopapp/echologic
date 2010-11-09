/**************************/
/*    SEARCH HISTORY      */
/**************************/

$(document).ready(function () {
  $.fragmentChange(true);

  bindHistoryEvents();
});

function bindHistoryEvents() {
	$("#search_form .submit_button").live("click", function(){
    setSearchHistory();
    return false;
  });

	$('#search_form #value').live("keypress", function(event) {
    if (event && event.keyCode == 13) { /* check if enter was pressed */
      setSearchHistory();
      return false;
    }
  });

  $("a.ajax_sort").live("click", function() {
    var sort = $(this).attr('value');
		$(':input[id=sort]').val(sort);
		setSearchHistory();
    return false;
  });

  $("a.ajax_no_sort").live("click", function() {
		$(':input[id=sort]').val('');
		setSearchHistory();
    return false;
  });
}



function setSearchHistory() {
  var val = $("#value").val();
  if (val.length > 0) {
    val = val.trim();
  }

  if ($(':input[id=sort]').length > 0) {
    var sort = $(':input[id=sort]').val();
	  $.setFragment({ "value": val, "sort" : sort, "page": "1"});
  } else {
    $.setFragment({ "value": val, "page": "1"});
  }
}



$(function() {
  $(".pagination a").live("click", function() {
    $.setFragment({ "page" : $.queryString(this.href).page });
    return false;
  });


  $(document).bind("fragmentChange.page", function() {
    $.getScript($.queryString(document.location.href, {"page" : $.fragment().page, "sort": $.fragment().sort , "value" : $.fragment().value}));
  });

  if ($.fragment().page) {
    $(document).trigger("fragmentChange.page");
  }
});


/*********************************************/
/*    CHILDREN PAGINATION AND SCROLLING      */
/*********************************************/

$(function() {
	$(".more_pagination a").live("click", function() {
		$(this).replaceWith($('<span/>').text($(this).text()).addClass('more_loading'));
  });
});


function pagination_scroll_down(element) {
	element.jScrollPane({animateTo: true});
  if (element.data('jScrollPanePosition') != element.data('jScrollPaneMaxScroll')) {
    element[0].scrollTo(element.data('jScrollPaneMaxScroll'));
  }

}
