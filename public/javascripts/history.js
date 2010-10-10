/**************************/
/*    SEARCH HISTORY      */
/**************************/


$(function() {
	 $("#search_form .submit_button").live("click", function(){
    setSearchHistory();
    return false;
  });

	$('#search_form #value').live("keypress", function(event) {
    if (event && event.keyCode == 13) { /* check if enter was pressed */
      setSearchHistory();
      return false;
    }
  })

  $(".ajax_sort").live("click", function() {
    var sort = $(this).attr('value');
		$(':input[id=sort]').val(sort);
		setSearchHistory();
    return false;
  });

  $(".ajax_no_sort").live("click", function() {
		$(':input[id=sort]').val('');
		setSearchHistory();
    return false;
  });
	$.fragmentChange(true);
});



function setSearchHistory() {
  val = $("#value").val().trim();
	if ($(':input[id=sort]').length) {
		sort = $(':input[id=sort]').val().trim();
		$.setFragment({ "value": val, "sort" : sort , "page": "1"});
	}
	else {
    $.setFragment({ "value": val, "page": "1"});
	}
}



$(function() {
  $(".pagination a").live("click", function() {
    $.setFragment({ "page" : $.queryString(this.href).page })
    return false;
  });

  $.fragmentChange(true);
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


function save_current_scroll(){
	return $('#children_list').data('jScrollPanePosition') == $('#children_list').data('jScrollPaneMaxScroll');
}

function pagination_scroll_down(id, current_scroll) {
	$(id).jScrollPane({animateTo: true});
  if (current_scroll)
  {
    $(id)[0].scrollTo($(id).data('jScrollPaneMaxScroll'));
  }

}
