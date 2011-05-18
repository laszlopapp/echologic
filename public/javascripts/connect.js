/* Do init stuff. */
$(document).ready(function () {
  if ($('#echo_connect_search').length > 0) {
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

