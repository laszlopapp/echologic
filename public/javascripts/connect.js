/* Do init stuff. */
$(document).ready(function () {
  if ($('#function_container.connect').length > 0) {
  	loadAvatarHolders();
  }
});


function loadAvatarHolders(){
	  $('#connect_results').delegate('.profile.active .avatar_holder', 'click', function(){
			$.scrollTo('body', 400, function() {$('#profile_details_container').animate(toggleParams, 500)});
	    $('.profile').removeClass('active');
	    return false;
		});
}

