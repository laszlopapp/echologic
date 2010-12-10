(function( $ ){

  var settings = {
      
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
		 insert: function (){},
		 loadAuthors: function (){},
		 updateSupport: function () {},
		 insertMore: function () {},
		 loadEchoMessages: function () {},
		 
		 
		 
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
