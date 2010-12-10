(function( $ ){

  var settings = {
      
    };

  function replaceOrInsert(element, template){
		if(element.length > 0) {
		element.replaceWith(template);
		}
		  else
		{
		collapseStatements();
		$('div#statements').append(template);
		}
	};
	
	function collapseStatements() {
		$('#statements .statement .header').removeClass('active').addClass('ajax_expandable');
		$('#statements .statement .content').hide('slow');
		$('#statements .statement .header .supporters_label').hide();
	};


  var methods = {
     init : function( options ) {

       
     },
		 insertContent: function(content){
		 	this.append(content);
		 },
		 showContent: function(){
		 	this.find('.content').animate(toggleParams, 500);
		 },
		 removeBelow: function(){
		 	this.nextAll().each(function(){
			/* delete the session data relative to this statement first */
			$('div#statements').removeData(this.id);
			$(this).remove();
			});
		 },
		 insert: function (level) {
		 	var element = $('div#statements .statement').eq(level);
		 	if(element.length > 0) {
	    element.replaceWith(this);
	    }
	      else
	    {
	    collapseStatements();
	    $('div#statements').append(this);
	    }
		 },
		 loadAuthors: function (authors, length){
		 	authors.insertAfter(this.find('.summary h2')).animate(toggleParams, 500);
			this.find('#authors_list').jcarousel({
			  scroll: 3,
				buttonNextHTML: "<div class='next_button'></div>",
				buttonPrevHTML: "<div class='prev_button'></div>",
				size: length
			});
		 },
		 updateSupport: function (action_bar, supporters_bar, supporters_label) {
		 	this.find('.action_bar').replaceWith(action_bar);
			this.find('.supporters_bar:first').replaceWith(supporters_bar);
			this.find('.supporters_label').replaceWith(supporters_label);
		 },
		 insertMore: function (level, type_id) {
		 	var element = $('#statements div.statement:eq(' + level + ') ' + type_id + ' .headline');
			this.insertAfter(element).animate(toggleParams, 500);
		 },
		 loadEchoMessages: function (messages) {
		 	 this.find('.action_bar').data('messages', messages);
		 },
		 
     show : function( ) {},
     hide : function( ) {},
     update : function( content ) {}
  };

  $.fn.statement = function( method ) {
    
    if ( methods[method] ) {
      methods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
    } else if ( typeof method === 'object' || ! method ) {
      methods.init.apply( this, arguments );
    } else {
      $.error( 'Method ' +  method + ' does not exist on jQuery.tooltip' );
    }    
    return this;
  };

})( jQuery );
