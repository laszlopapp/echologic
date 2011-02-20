/* Do init stuff. */

$(document).ready(function () {
  loadComponentAutoComplete();
	loadProfileEditForm();
});


function loadComponentAutoComplete() {
  $('#membership_container form #membership_organisation').livequery(function() {
    $(this).autocomplete("users/memberships/auto_complete_for_membership_organisation",
                         {minChars: 3, selectFirst: false});
  });
  $('#membership_container form #membership_position').livequery(function() {
    $(this).autocomplete("users/memberships/auto_complete_for_membership_position",
                         {minChars: 3, selectFirst: false});
  });
  $('#concernment_container form .tag_value_autocomplete').livequery(function() {
    $(this).autocomplete("users/users/auto_complete_for_tag_value",
                         {minChars: 3, selectFirst: false});
  });
}


function loadProfileEditForm() {
  $('form#edit_profile_form').livequery(function () {

    $(this).find(':input').focus(function() {
      $(this).toggleClass('active');
    });
    $(this).find(':input').blur(function() {
      $(this).toggleClass('active');
    });
    $(this).find("#profile_city").autocomplete("users/profile/auto_complete_for_profile_city",
                                               {minChars: 3, selectFirst: false});
    $(this).ajaxForm({ dataType : 'script' });
  });
}