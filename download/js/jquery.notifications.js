/*
 * jQuery Notifications plugin 1.1
 *
 * http://programmingmind.com
 *
 * Copyright (c) 2009 David Ang
 *
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 *   
 *   Version Changes
 *   
 *   1.1 8/17/2008
 *   - Allow users to choose between slide or fade effect
 *   - Fixed fadeSpeed option settings   
 *   
 *   1.0 8/9/2008
 *    - Initial release
 */
(function($){
    var template;
    var counter = 0;
	
    $.notifications = function(msg, options) {
        counter++;
        
        var settings = $.extend({}, $.notifications.defaults, options);
        
		if (!template) {
        	template = $('<div id="jquery-notifications"></div>').appendTo(document.body);
		}

		var n = $( '<p class="' + settings.type + ' ui-corner-all" id="jquery-notifications-' + counter + '">' + msg + '</p>').hide().appendTo("#jquery-notifications");
		if( settings.effect == "fade" ) {
			n.fadeIn( settings.fadeSpeed );
		} else {
			n.slideDown( settings.fadeSpeed );
		}

		if (settings.stick) {
			var close = $('<a href="javascript:void(0);">' + settings.close + '</a>').click(function() {
				if (settings.effect == "fade") {
					$(this.parentNode).fadeOut( settings.fadeSpeed, function() {
						$(this).remove();
					});
				}
				else {					
					$(this.parentNode).slideUp( settings.fadeSpeed, function() {
						$(this).remove();
					});					
				}
			});
			close.appendTo(n);
		}		
    	
		if (!settings.stick) {
			var notificationsDelayer = delayTimer(settings.timeout);
			notificationsDelayer(update, { counter: counter, effect: settings.effect, fadeSpeed : settings.fadeSpeed } );
		}
		
		if ($("#errorExplanation").length) {
			// if there exists an errorExplanation div from rails 3.0,
		  	// hide the errors and list them down as notifications
      	  	$("#errorExplanation").hide();
      	  	$("#errorExplanation li").each(function(index) {
        		$.n.error($(this).text());
      		})
		}
	};
	
	$.notifications.success = function( msg, options ){		
        return $.notifications( msg, $.extend( {}, options, { type : "success"}) );
    };
	
    $.notifications.error = function( msg, options ){
        return $.notifications( msg, $.extend( { stick: true }, options, { type : "error" }) );
    };
	
    $.notifications.warning = function( msg, options ){
        return $.notifications( msg, $.extend( {}, options, { type : "warning" }) );
    };	
    
	function update(params) {				
		if (params.effect == "fade") {
			$("#jquery-notifications-" + params.counter).fadeOut( params.fadeSpeed, function(){
				$(this).remove();
			});
		} else {
			$("#jquery-notifications-" + params.counter).slideUp( params.fadeSpeed, function(){
				$(this).remove();
			});			
		}
	}
	
	function delayTimer(delay) {
	    var timer;
	    return function(fn, params) {
	        timer = clearTimeout(timer);
	        if (fn)
	            timer = setTimeout(function() {
	                fn(params);
	            }, delay);
	        return timer;
	    };
	}	

	$.notifications.defaults = {
            type: "notice",
			timeout: 10000,
			stick: false,
			fadeSpeed : 800,
			close : "x",
			effect : "fade"
        };
    
	$.n = $.notifications;	 
	
})(jQuery);