/* Do init stuff. */
$(document).ready(function () {
	
  loadComponentAjaxForms();
  
  loadComponentAutoComplete();
	
	loadProfileEditForm();	
});

/* Makes all Component forms ajax */
function loadComponentAjaxForms() {
  $('form.component').livequery(function () {
    $(this).ajaxForm({ dataType : 'script' });
  });
}

function loadComponentAutoComplete() {
  $('form.component .tag_value_autocomplete').livequery(function(){
    $(this).autocomplete("users/users/auto_complete_for_tag_value", {minChars: 3, selectFirst: false});
  });
}


function loadProfileEditForm() {
  $('form#edit_profile_form').livequery(function () {
		$(this).find(':file').css({'-moz-border-radius':'4px', border:"1px solid #ccc"});

    $(this).find(':input').focus(function() {
      $(this).toggleClass('active');
    });

    $(this).find(':input').blur(function() {
      $(this).toggleClass('active');
    });

    $(this).find("#user_city").autocomplete("users/users/auto_complete_for_user_city");
    $(this).find("#user_country").autocomplete("users/users/auto_complete_for_user_country");

    $(this).ajaxForm({ dataType : 'script' });
  });
}