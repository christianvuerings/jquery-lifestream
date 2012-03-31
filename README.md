# jQuery Lifestream Plug-in

![jQuery Lifestream Logo](http://christianv.github.com/jquery-lifestream/design/logo_v1_64.png)

Show a stream of your online activity.  
Check out [the example][example] or create [your own lifestream][melifestream] instantly.

[![Follow us on twitter](http://f.cl.ly/items/2z1p0w320g1q0T061m1u/twitter_follow.png)](http://twitter.com/jq_lifestream)

## Requirements
* [jQuery 1.4.2+](http://www.jquery.com)

## Supported feeds

Currently supports the following feeds:

* [Bitbucket](https://bitbucket.org/)
* [Bitly](http://bitly.com)
* [Blogger](http://blogger.com)
* [Citeulike](http://www.citeulike.org)
* [Digg](http://digg.com)
* [Dailymotion](http://dailymotion.com)
* [Delicious](http://delicious.com)
* [DeviantART](http://deviantart.com)
* [Dribbble](http://dribbble.com)
* [Facebook Pages](http://www.facebook.com/pages)
* [Flickr](http://flickr.com)
* [Foomark](http://foomark.com)
* [Formspring](http://formspring.com)
* [Forrst](http://forrst.com)
* [Foursquare](http://foursquare.com)
* [Gimmebar](http://gimmebar.com)
* [Github](http://github.com)
* [Google+](http://plus.google.com)
* [Google Reader](http://google.com/reader)
* [Instapaper](http://www.instapaper.com)
* [Iusethis](http://osx.iusethis.com/)
* [Last.fm](http://last.fm)
* [LibraryThing.com](http://librarything.com)
* [Mlkshk](http://mlkshk.com)
* [PicPlz](http://picplz.com)
* [Pinboard](http://pinboard.com)
* [Posterous](http://posterous.com)
* [Reddit](http://reddit.com)
* [RSS](http://en.wikipedia.org/wiki/RSS)
* [Slideshare](http://slideshare.com)
* [Snipplr](http://snipplr.com)
* [Stackoverflow](http://stackoverflow.com)
* [Tumblr](http://tumblr.com)
* [Twitter](http://twitter.com)
* [Vimeo](http://vimeo.com)
* [Wikipedia](http://wikipedia.com)
* [Wordpress](http://wordpress.com)
* [Youtube](http://youtube.com)
* [Zotero](http://zotero.com)

Feel free to fork the project and add your own feeds in.  
Just send a pull request to [christianv/jquery-lifestream][jquery-lifestream] when you're finished.

## Extensions

* [Filter feeds](https://gist.github.com/1170205) - used by [codeandstuff.com](http://www.codeandstuff.com/)
* [Drupal module](http://drupal.org/project/social_river) - jQuery lifestream as a drupal module called Social River.

## Build

    cd build
    make

### Available targets

Use `make target` and replace _target_ with the target you want to use.

* **jls**:
  Build jquery.lifestream.js, the non-minified version of jQuery Lifestream
* **jls-min**: 
  Build jquery.lifestream.min.js, the minified version of jQuery Lifestream
* **script-min**:
  Build download/js/script.min.js, this script is the main script for the
  download page
* **uglifyjs**: 
  Build download/js/uglify-cs.js, a custom version of UglifyJS patched
  to work in the browser
* **uglifyjs-min**:
  Build download/js/uglify-cs.min.js, minified version of UglifyJS
* **service-list**:
  Build download/services.json, a list of all the services which are available

### Requirements

* [Node](https://github.com/joyent/node/wiki/Installation)
* [Npm](http://npmjs.org/)
* [UglifyJS](https://github.com/mishoo/UglifyJS/)

## Usage

Add the following to the &lt;head&gt; or &lt;body&gt; tag of your HTML page.

``` html
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"></script>
<script src="https://raw.github.com/christianv/jquery-lifestream/master/jquery.lifestream.min.js"></script>
<script>
  $("#lifestream").lifestream({
    list:[
      {
        service: "github",
        user: "christianv"
      },
      {
        service: "twitter",
        user: "denbuzze"
      }
    ]
  });
</script>
```
The above code will always use the latest version of the script.  
If you want to use it in production, download the [minified](https://github.com/christianv/jquery-lifestream/raw/master/jquery.lifestream.min.js)
or [uncompressed](https://github.com/christianv/jquery-lifestream/raw/master/jquery.lifestream.js) file and host it yourself.

### jQuery Templates

You have the ability to use jQuery templates for your feed.  
Checkout the [template page](http://christianv.github.com/jquery-lifestream/template.html) to see an overview of the current available templates.

Usage:

``` javascript
{
  service: 'deviantart',
  user: 'gabbyd70',
  template: {
    deviationpost: 'heeft hetvolgende gepost: <a href="${url}">${title}</a>'
  }
}
```

## Configuration

The plug-in accepts one configuration JSON object:

``` javascript
$("#lifestream").lifestream({
  classname: "lifestream",
  feedloaded: feedcallback,
  limit: 30,
  list:[
    {
      service: "github",
      user: "christianv"
    },
    {
      service: "twitter",
      user: "denbuzze"
    }
  ]
});
```

`classname`: The name of the main lifestream class. We use this for the main ul class e.g. lifestream and for the specific feeds e.g. lifestream-twitter

`feedloaded`: (_function_) A callback function which is triggered each time a feed was loaded.

`limit`: (_integer_) Specify how many elements you want in your lifestream (default = 10).

`list`: (_array_) Array containing other JSON objects with information about each item.  
Each item should have a _service_ and a _user_.  
For more information about each _service_, check out the [source code][examplesource] of the [example page][example].

## Commit to the project

### Add your own feed

Adding in your own feed is pretty easy.  
Have a look at [this commit](https://github.com/christianv/jquery-lifestream/commit/529a06db159b4123ee3b2cc604f3a3ed698c6e9a) which adds support for the last.fm feed.

### Create data:URI for an icon

1. [Convert](http://converticon.com/) the favicon.ico of a site to a .png file. (e.g. http://google.com/favicon.ico)
2. [Make](http://www.dopiaza.org/tools/datauri/) a data:URI for it.
3. Put the data:URI in css/lifestream.css (alphabetical order).

### How to commit?

1. Push the finished code to your own remote repository.
2. Send a pull request to [christianv/jquery-lifestream][jquery-lifestream].

### Code Style Guidelines

* Indentation: 2 spaces
* Max column width: 78 characters
* Trailing spaces: not allowed
* Always use curly brackets {} for if/else/for
* Put all `var` statements in the beginning of a function
* Use === & !== for comparing variables
* Use the following spacing rules:
``` javascript
for (var i = 0, j = length; i < j; i++) {
```

## Ideas
Stuff that isn"t implemented yet, but would be nice to have:

* Add support for [Twitter Web Intents](http://dev.twitter.com/pages/intents)

## Mentions

Places on the web where this plug-in got mentioned:

* [Andref.it](http://andref.it/blog/2011/aggrega-la-tua-attivita-online-con-jquery-lifestream/) - Italian
* [BlogUpstairs](http://blogupstairs.com/framework/javascript-framework/jquery/jquery-lifestream-show-a-stream-of-your-online-activity-with-jquery/)
* [Codevisually](http://codevisually.com/jquery-lifestream-create-a-stream-of-your-online-activity/)
* [DailyJS](http://dailyjs.com/2011/06/21/jquery-roundup/)
* [DesignBeep](http://designbeep.com/2011/06/02/17-fresh-and-functional-jquery-plugins-you-will-love/)
* [Devl.im](http://devl.im/jquery-lifestream-show-a-stream-of-your-online-activity/)
* [Doejo](http://doejo.com/blog/jquery-lifestream-a-simple-way-to-track-your-online-activity-in-one-spot)
* [Eire Media](http://repo.eire-media.com/go/)
* [Elliptips](http://elliptips.info/2011/09/lifestream-votre-vie-virtuelle-sous-forme-de-timeline-en-jquery/) - French
* [Erik Ostrom Blog](http://slapdash.erikostrom.com/post/9797738423/just-finally-added-something-to-my-ostensible-web)
* [doejo](http://doejo.com/blog/jquery-lifestream-a-simple-way-to-track-your-online-activity-in-one-spot)
* [HTML.it](http://javascript.html.it/script/vedi/6468/le-nostre-attivita-su-internet-con-il-plugin-jquery-lifestream/) - Italian
* [Hypem](http://hypem.com/)
* [jQuery Rain](http://www.jqueryrain.com/2011/06/jquery-lifestream/)
* [jqueryitalia](http://twitter.com/jqueryitalia/status/77999618046169088)
* [Lifestream Blog](http://lifestreamblog.com/create-a-dynamic-activity-stream-with-the-jquery-lifestream-script/)
* [Simong Gaeremynck Blog](http://blog.gaeremynck.com/jquery-lifestream-and-followmy-tv/)
* [Softpedia](http://webscripts.softpedia.com/script/Modules/jQuery-Plugins/jQuery-Lifestream-68762.html) - Softpedia pick
* [Speckyboy](http://speckyboy.com/2011/12/07/the-50-most-useful-jquery-plugins-from-2011/)
* [Spyrestudios](http://spyrestudios.com/31-fantastic-new-jquery-plugins-for-web-developers/)
* [phpspot](http://phpspot.org/blog/archives/2011/06/jquerylifestrea.html) - Japanese
* [ProgrammableWeb](http://www.programmableweb.com/mashup/jquery-lifestream) - Mashup of the Day on 17/06/2011
* [Smashing Magazine](http://twitter.com/smashingmag/status/77993263981797376)
* [Tactoom.com](http://tactoom.com/interest/Hardcore/4ed34793de3b117715002952)
* [The Changelog](http://thechangelog.com/post/7262848148/jquery-lifestream-show-a-stream-of-your-online-activity)
* [The Next Web](http://thenextweb.com/dd/2011/07/08/jquery-lifestream-makes-it-easy-to-pop-your-online-activity-onto-any-page/)
* [Weboptimize](http://www.aranda.se/2011/12/17/10-interesting-jquery-plugins/)

## Used By

A list of sites that use the jQuery Lifestream plug-in:

[Alex Buznik (Russian)](http://buznik.net/j/my-social-media), 
[Armin Roșu](http://armin.ro/), 
[Bender Rodriges](http://bbrodriges.github.com/blog/), 
[Blake Embrey](http://blakeembrey.me/#lifestream), 
[BrainDump2.0](http://mgiulio.altervista.org/), 
[Dennis Metzcher](http://lifestream.metzcher.com/), 
[Erik Ostrom](http://www.erikostrom.com/), 
[Libby Baldwin](http://libbybaldwin.github.com/), 
[Robbie.io](http://robbie.io/life.html), 
[Sam Tardif](http://www.codeandstuff.com/), 
[Sebastix](http://www.sebastix.nl/), 
[Simon Gaeremynck](http://gaeremynck.com/), 
[Sunny Walker](http://miraclesalad.com/)

## Special Thanks

Special thanks all the [committers](https://raw.github.com/christianv/jquery-lifestream/master/COMMITTERS) and [gabbyd70](http://gabbyd70.deviantart.com/) for letting us use her DeviantART username.

## Version log

* 0.3.0 RSS support
* 0.2.9 Hypem support
* 0.2.8 Gimmebar support
* 0.2.7 Zotero support
* 0.2.6 Google+ support
* 0.2.5 Wikipedia support
* 0.2.4 LibraryThing support
* 0.2.3 Digg support
* 0.2.2 Facebook Pages support
* 0.2.1 Bitbucket support
* 0.2.0 Modular builds
* 0.1.6 Bitly support
* 0.1.5 Snipplr support
* 0.1.4 Instapaper support
* 0.1.3 Mlkshk support
* 0.1.2 Foomark support
* 0.1.1 Blogger, Formspring, Posterous & Wordpress support
* 0.1.0 jQuery Template support
* 0.0.17 Forrst & PicPlz support
* 0.0.16 Iusethis support
* 0.0.15 Dailymotion & Pinboard support
* 0.0.14 Slideshare support
* 0.0.13 Vimeo support
* 0.0.12 Reddit support
* 0.0.11 Tumblr support
* 0.0.10 DeviantART support
* 0.0.9 Foursquare support
* 0.0.8 Add support for Github tags
* 0.0.7 Dribbble support
* 0.0.6 Update links in twitter to be able to have hashes in them
* 0.0.5 Flickr support
* 0.0.4 Last.fm support
* 0.0.3 Delicious support + minor bug fix in the stackoverflow code
* 0.0.2 Youtube support
* 0.0.1 Initial version


[jquery-lifestream]: https://github.com/christianv/jquery-lifestream
[melifestream]: http://christianv.github.com/jquery-lifestream/me/
[example]: http://christianv.github.com/jquery-lifestream/example.html 
"Example page"
[examplesource]: https://github.com/christianv/jquery-lifestream/blob/master/example.html#files "Source code of the example page"