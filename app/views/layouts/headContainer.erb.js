/**
 * Template to change static menu, tabs and static content via JS.
 */

/* Write render output into JS variables for later use. */
var content = "<%= escape_javascript(render(:partial => request[:action])) %>";

/* If echologic container isn't visible, toggle it and hide tab container.
 * For parameter details see toggleParams in application.js */
$('#echologicContainer:hidden').animate(toggleParams, 500,
    function() { $('#tabContainer').animate(toggleParams, 500); });

/* Change css class through javascript for setting state of staticMenu.
 * echologic and outer menu parts will show echologic menu item. */
changeMenuImage('echologic');

/* Replace content with new rendered content. */
$('#staticContent').hide();
$('#staticContent').html(content);
$('#staticContent').appear(400);

/* Bind click event handlers for more and hide buttons. */
bindMoreHideButtonEvents();

/* Render tooltips. */
makeQTips();

/* Bind click event handlers for more and hide buttons. */
bindMoreHideButtonEvents();