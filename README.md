# jQuery Lifestream Plug-in

![jQuery Lifestream Logo](http://christianv.github.com/jquery-lifestream/design/logo_v1_64.png)

Show a stream of your online activity.  
Check out [the example][example] or create [your own lifestream][melifestream] instantly.

[![Follow us on twitter](http://f.cl.ly/items/2z1p0w320g1q0T061m1u/twitter_follow.png)](http://twitter.com/jq_lifestream)

## Requirements
* [jQuery 1.4.2+](http://www.jquery.com)

## Supported feeds

Currently supports the following feeds:

* [Blogger](http://blogger.com)
* [Dailymotion](http://dailymotion.com)
* [Delicious](http://delicious.com)
* [DeviantART](http://deviantart.com)
* [Dribbble](http://dribbble.com)
* [Flickr](http://flickr.com)
* [Foomark](http://foomark.com)
* [Formspring](http://formspring.com)
* [Forrst](http://forrst.com)
* [Foursquare](http://foursquare.com)
* [Github](http://github.com)
* [Google Reader](http://google.com/reader)
* [Iusethis](http://osx.iusethis.com/)
* [Last.fm](http://last.fm)
* [Mlkshk](http://mlkshk.com)
* [PicPlz](http://picplz.com)
* [Pinboard](http://pinboard.com)
* [Posterous](http://posterous.com)
* [Reddit](http://reddit.com)
* [Slideshare](http://slideshare.com)
* [Stackoverflow](http://stackoverflow.com)
* [Tumblr](http://tumblr.com)
* [Twitter](http://twitter.com)
* [Vimeo](http://vimeo.com)
* [Wordpress](http://wordpress.com)
* [Youtube](http://youtube.com)

Feel free to fork the project and add your own feeds in.  
Just send a pull request to [christianv/jquery-lifestream][jquery-lifestream] when you're finished.

## Usage

Add the following to the &lt;head&gt; or &lt;body&gt; tag of your HTML page.

``` html
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"></script>
<script src="https://raw.github.com/christianv/jquery-lifestream/master/jquery.lifestream-compiled.js"></script>
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
If you want to use it in production, download the [compressed](https://github.com/christianv/jquery-lifestream/raw/master/jquery.lifestream-compiled.js)
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
* We use the following spacing rules:
``` javascript
for (var i = 0, j = length; i < j; i++) {
```

## Ideas
Stuff that isn"t implemented yet, but would be nice to have:

* Add support for [Twitter Web Intents](http://dev.twitter.com/pages/intents)

## Mentions

Places on the web where this plug-in got mentioned:

* [Smashing Magazine](http://twitter.com/smashingmag/status/77993263981797376)
* [DesignBeep](http://designbeep.com/2011/06/02/17-fresh-and-functional-jquery-plugins-you-will-love/)
* [jqueryitalia](http://twitter.com/jqueryitalia/status/77999618046169088)
* [HTML.it](http://javascript.html.it/script/vedi/6468/le-nostre-attivita-su-internet-con-il-plugin-jquery-lifestream/) - Italian
* [phpspot](http://phpspot.org/blog/archives/2011/06/jquerylifestrea.html) - Japanese
* [DailyJS](http://dailyjs.com/2011/06/21/jquery-roundup/)
* [ProgrammableWeb](http://www.programmableweb.com/mashup/jquery-lifestream) - Mashup of the Day on 17/06/2011
* [Softpedia](http://webscripts.softpedia.com/script/Modules/jQuery-Plugins/jQuery-Lifestream-68762.html) - Softpedia pick
* [jQuery Rain](http://www.jqueryrain.com/2011/06/jquery-lifestream/)
* [BlogUpstairs](http://blogupstairs.com/framework/javascript-framework/jquery/jquery-lifestream-show-a-stream-of-your-online-activity-with-jquery/)
* [The Changelog](http://thechangelog.com/post/7262848148/jquery-lifestream-show-a-stream-of-your-online-activity)

## Special Thanks

Special thanks all the [committers](https://raw.github.com/christianv/jquery-lifestream/master/COMMITTERS) and [gabbyd70](http://gabbyd70.deviantart.com/) for letting us use her DeviantART username.

## Version log

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