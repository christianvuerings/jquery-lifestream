Canvas files are used to customize the Canvas experience.

In the Canvas admin UI there are fields that point to the canvas-skin.css and canvas-customization.js files which in turn reference the other files in this folder.

Current customizations are:

- styling the Canvas header and adding a CalCentral Dashboard button at the top of the page.

	using Javascript we insert into the Canvas #topbar element:
    	<ul id="calcentral-custom-header">
        	<li class="my-dashboard">
            	<a href="https://calcentral.berkeley.edu/dashboard">CalCentral Dashboard</a>
        	</li>
    	</ul>


- modifying and styling the Canvas footer to include the Berkeley logo and some text about the Canvas pilot project.

	using Javascript we wrap the <span> element in the footer in a div and insert a <p> with content at the before the span. The completed div should look like this:

	<div>
		<p><span>Canvas Pilot,</span> part of the <a href="http://ets.berkeley.edu/bspace-replacement">bSpace Replacement project</a></p>
		<span id="footer-links">
        	<a href="http://help.instructure.com/" class="support_url help_dialog_trigger" data-track-category="help system" data-track-label="help button">Help</a>
        	<a href="http://www.instructure.com/privacy-policy">Privacy policy</a>
			<a href="http://www.instructure.com/terms-of-use">Terms of service</a>
			<a href="http://facebook.com/instructure">Facebook</a>
			<a href="http://twitter.com/instructure">Twitter</a>
		</span>
	</div>
