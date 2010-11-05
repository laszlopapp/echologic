$(document).ready(function () {
  initHistoryEvents();
	
	initPaginationButtons();
	
	initFragmentChange();
});


/**************************/
/*    SEARCH HISTORY      */
/**************************/


function initHistoryEvents() {
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
};



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

/**********************/
/*    PAGINATION      */
/**********************/

function initPaginationButtons() {
	$(".pagination a").live("click", function() {
    $.setFragment({ "page" : $.queryString(this.href).page })
    return false;
  });
  $.fragmentChange(true);
}


function initFragmentChange() {
  $(document).bind("fragmentChange.page", function() {
		if ($.fragment().page) {
			$.getScript($.queryString(document.location.href, {
				"page": $.fragment().page,
				"sort": $.fragment().sort,
				"value": $.fragment().value
			}));
		}
  });
  
  if ($.fragment().page) {
    $(document).trigger("fragmentChange.page");
  }
}


