$(function() {
  $(".pagination a").live("click", function() {
    $.setFragment({ "page" : $.queryString(this.href).page })
    return false;
  });
  
  $.fragmentChange(true);
  $(document).bind("fragmentChange.page", function() {
    $.getScript($.queryString(document.location.href, { "page" : $.fragment().page }));
  });
  
  if ($.fragment().page) {
    $(document).trigger("fragmentChange.page");
  }
});

$(function() {
	$(".more_pagination a").live("click", function() {
		$('.pagination_loading').animate(toggleParams).show();
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
