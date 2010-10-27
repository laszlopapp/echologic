/* Do init stuff. */
$(document).ready(function () {
  
  loadAvatarHolders();
  
	loadReportAjaxForm();
	
});


function loadAvatarHolders(){
	$('.profile.active .avatar_holder').live("click", function() {
    $.scrollTo('top', 400, function() {$('#profile_details_container').animate(toggleParams, 500)});
    $('.profile').removeClass('active');
    return false;
  });
}

/* Makes Report forms ajax */
function loadReportAjaxForm() {
  $('form.report_form').livequery(function () {
		$(this).ajaxForm({ dataType : 'script' });
  });
}