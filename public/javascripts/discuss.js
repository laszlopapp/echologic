function collapseStatements() {
	$('#statements .statement .header').removeClass('active');
	$('#statements .statement .content').hide();
	$('#statements .statement .supporters_label').hide();
};

function replaceOrInsert(element, template){
	if(element.length > 0) {
		element.replaceWith(template);
	}
  else 
	{
		$('#statements').append(template);
	}
};

function removeChildrenStatements(element){
	element_index = $('#statements div.statement').index(element);
	if(element_index >= 0) {
	  $('#statements .statement').map(function(index){
	    if(index > element_index) {$(this).remove();}
	})};
};
