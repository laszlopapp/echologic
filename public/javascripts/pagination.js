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

$(".more_pagination a").live("click", function() {
  $('.more_pagination').html('<span class="pagination_loading"></span>');
});