/* Do init stuff. */

$(document).ready(function () {
  loadComponentAutoComplete();
	loadProfileEditForm();
	initEchoAccountButtons();
});


function loadComponentAutoComplete() {
  var options = {minChars: 3, selectFirst: false};
  $('#membership_container form #membership_organisation').livequery(function() {
    $(this).autocomplete("users/memberships/auto_complete_for_membership_organisation", options);
  });
  $('#membership_container form #membership_position').livequery(function() {
    $(this).autocomplete("users/memberships/auto_complete_for_membership_position", options);
  });
  $('#concernment_container form .tag_value_autocomplete').livequery(function() {
    $(this).autocomplete("users/users/auto_complete_for_tag_value",
                         {minChars: 3, selectFirst: false, multiple: true});
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


function initEchoAccountButtons() {
	var container = $('#echo_account_settings');
	$('#echo_account_settings').find('a.header').live('click', function(){
		var button = $(this);
		if (!$(this).hasClass('active')) {
			var content = container.children('.content');

			$.ajax({
				url: button.attr('href'),
				type: 'get',
				dataType: 'script',
				success: function(){
					button.addClass('active').siblings().removeClass('active');

					if (content) {
					  content.replaceWith(container.children(':last').show());
					} else {
						container.children('.content').animate(toggleParams, 500);
					}
				},
				error: function(){

				}
			});
	 }
	 return false;
	});
}
