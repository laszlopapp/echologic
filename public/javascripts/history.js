/**************************/
/*    SEARCH HISTORY      */
/**************************/


var $j = jQuery.noConflict();

$j(document).ready(function () {
  bindHistoryEvents();
});

function bindHistoryEvents() {
	 $j("#search_form .submit_button").live("click", function(){
    setSearchHistory();
    return false;
  });
	
	$j('#search_form #value').live("keypress", function(event) { 
    if (event && event.keyCode == 13) { /* check if enter was pressed */
      setSearchHistory();
      return false;
    }
  })
	
  $j(".ajax_sort").live("click", function() {
    var sort = $j(this).attr('value');
		$j(':input[id=sort]').val(sort);
		setSearchHistory();
    return false;
  });

  $j(".ajax_no_sort").live("click", function() {
		$j(':input[id=sort]').val('');
		setSearchHistory();
    return false;
  });
	$j.fragmentChange(true);
};



function setSearchHistory() {
  val = $j("#value").val().trim();
	if ($j(':input[id=sort]').length) {
		sort = $j(':input[id=sort]').val().trim();
		$j.setFragment({ "value": val, "sort" : sort , "page": "1"});
	}
	else {
    $j.setFragment({ "value": val, "page": "1"});
	} 
}



$j(function() {
  $j(".pagination a").live("click", function() {
    $j.setFragment({ "page" : $j.queryString(this.href).page })
    return false;
  });
  
  $j.fragmentChange(true);
  $j(document).bind("fragmentChange.page", function() {
		$j.getScript($j.queryString(document.location.href, {"page" : $j.fragment().page, "sort": $j.fragment().sort , "value" : $j.fragment().value}));
  });
  
  if ($j.fragment().page) {
    $j(document).trigger("fragmentChange.page");
  }
});


/*********************************************/
/*    CHILDREN PAGINATION AND SCROLLING      */
/*********************************************/
$j(function() {
	$j(".more_pagination a").live("click", function() {
		$j(this).replaceWith($j('<span/>').text($j(this).text()));
		$j(".more_pagination").append($j('<span/>').addClass('pagination_loading'));
  });
});


function save_current_scroll(){
	return $j('#children_list').data('jScrollPanePosition') == $j('#children_list').data('jScrollPaneMaxScroll');
}

function pagination_scroll_down(id, current_scroll) {
	$j(id).jScrollPane({animateTo: true});
  if (current_scroll)
  {
    $j(id)[0].scrollTo($j(id).data('jScrollPaneMaxScroll'));
  }

}
