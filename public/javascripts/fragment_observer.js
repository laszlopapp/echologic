// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var $j = jQuery.noConflict();

/* Do init stuff. */
$j(document).ready(function () {

  startFragmentObservation();
 
});

// TODO robustness: if no script can be found make http request.
function startFragmentObservation() {
  /* Turn on fragment observation through jQuery plugin. */
  $j.fragmentChange(true);

  /* Do AJAX call on fragment change events for goto. */
  $j(document).bind("fragmentChange", function() {
    if (getActionFromHash()) {
      $j.getScript(getControllerFromHash()+'/'+getActionFromHash());
    } else {
      $j.getScript(getControllerFromHash());
    }
  });

  /* If fragment is present on document load trigger fragmentChange event. */
  if (fragmentPresent()) {
    $j(document).trigger("fragmentChange");
  }
}

/* splits the hash of a location and returns the name of the controller */
function getControllerFromHash() {
  // leading slash is required!
  return '/'+currentLocale+'/'+document.location.hash.split('/')[1];
}

function getActionFromHash() {
  return document.location.hash.split('/')[2];
}

function fragmentPresent() {
    return document.location.hash.length > 0 ? true : false;
}