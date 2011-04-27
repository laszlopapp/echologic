/*
    jQuery plugin to detect horizontal swipes on elements.
    It is an adjustment of Steve Gough's jFlick plugin.
*/


(function($) {
    $.fn.detectFlicks = function(options) {

        //for reference only
        var LeftToRight = 'left2right',
            RightToLeft = 'right2left',
            UpToDown = 'up2down',
            DownToUp = 'down2up';

        var flickController = {
            direction: '',
            isFlick: false
        };

        var defaults = {
            threshold: 15,
            axis: 'x',
            flickEvent: function() { return true; }
        };

        var options = $.extend(defaults, options);

        flickController.touchStart = function(e) {
            var $el = $(e.target);
            // this is where the touch was first detected
            this.isFlick = false;
            this.startX = event.targetTouches[0].clientX;
            this.startY = event.targetTouches[0].clientY;
            if (options.axis == 'y') {
                $el.bind('touchmove', flickController.touchMoveY);
            }
            else {
                $el.bind('touchmove', flickController.touchMoveX);
            }

            $el.bind('touchend', flickController.touchEnd);
        };

        flickController.touchMoveX = function(e) {

            event.preventDefault(); //no scrolling
            this.movedX = event.targetTouches[0].clientX;
            if (Math.abs(Math.abs(this.movedX) - Math.abs(this.startX)) > options.threshold) {
                this.isFlick = true;
                if (this.movedX > this.startX) {
                    flickController.direction = LeftToRight;
                }
                else {
                    flickController.direction = RightToLeft;
                }
            }
        };

        flickController.touchMoveY = function(e) {

            event.preventDefault(); //no scrolling
            this.movedY = event.targetTouches[0].clientY;
            if (Math.abs(Math.abs(this.movedY) - Math.abs(this.startY)) > options.threshold) {
                this.isFlick = true;
                if (this.movedY > this.startY) {
                    flickController.direction = UpToDown;
                }
                else {
                    flickController.direction = DownToUp;
                }
            }
        };

        // Evaluate the custom code if a flick was detected
        flickController.touchEnd = function(e) {
            var $el = $(e.target);
            if (this.isFlick) {
                options.flickEvent({ direction: flickController.direction });
            }
            $el.unbind('touchmove touchend');
        };

        obj = $(this);
        obj.bind('touchstart', flickController.touchStart);

        return flickController;
    };
})(jQuery);
