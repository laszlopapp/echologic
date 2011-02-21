/* Do init stuff. */
$(document).ready(function () {
	
  loadComponentAutoComplete();
	
	loadProfileEditForm();	
	initEchoAccountButtons();
});



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

function initEchoAccountButtons() {
	var container = $('#echo_account_settings');
	$('#echo_account_settings').find('a.header').live('click', function(){
		var button = $(this);
		if (!$(this).hasClass('active')) {
			var content = container.children('.content');
			if (content.length > 0) {
				content.slideUp(500, function(){
			   $(this).remove();
			  });
			}
			$.ajax({
				url: button.attr('href'),
				type: 'get',
				dataType: 'script',
				success: function(){
					button.addClass('active').siblings().removeClass('active');
					container.children('.content').slideDown(500);
				},
				error: function(){
				
				}
			});
	 }
	 return false;
	});
}
