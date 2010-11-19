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

/**********************/
/*    PAGINATION      */
/**********************/

function initPaginationButtons() {
	$(".pagination a").live("click", function() {
    $.setFragment({ "page" : $.queryString(this.href).page })
    return false;
  });
}


function initFragmentChange() {
  $(document).bind("fragmentChange.page", function() {
		path = document.location.href.split('/');
		/* if path had a search value before, then clean it */
		if (!path[path.length - 1].match('search')) {
			path.pop();
		}
		/* clean fragments on path */
		path[path.length - 1] = 'search';
		/* push new search value */
		if ($.fragment().value) {
			path.push(escape($.fragment().value));
		}
		if ($.fragment().page) {
			$.getScript($.queryString(path.join('/'), {
				"page": $.fragment().page,
				"sort": $.fragment().sort,
			}));
		}
  });

  if ($.fragment().page) {
    $(document).trigger("fragmentChange.page");
  }
}
