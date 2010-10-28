/* Do init stuff. */
$(document).ready(function () {
  
  loadAvatarHolders();
  
});


function loadAvatarHolders(){
	$('.profile.active .avatar_holder').live("click", function() {
    $.scrollTo('top', 400, function() {$('#profile_details_container').animate(toggleParams, 500)});
    $('.profile').removeClass('active');
    return false;
  });
}

