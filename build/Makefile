srcPath = ../src
servicesDir = $(srcPath)/services
buildDir = .
dist = ../dist
modules = $(srcPath)/core.js $(servicesDir)/*.js
serviceListPath = ../download/services.txt
jls = $(dist)/jquery.lifestream.js
jlsMin = $(dist)/jquery.lifestream.min.js
uglifyOpts =
# minifiedModules = $(dist)/*.min.js
#minifiedServiceModules := $(patsubst %.js,%.min.js,$(wildcard $(servicesDir)/*.js))
minifiedModules = $(dist)/core.min.js\
$(dist)/blogger.min.js\
$(dist)/dailymotion.min.js\
$(dist)/delicious.min.js\
$(dist)/deviantart.min.js\
$(dist)/dribbble.min.js\
$(dist)/flickr.min.js\
$(dist)/foomark.min.js\
$(dist)/formspring.min.js\
$(dist)/forrst.min.js\
$(dist)/foursquare.min.js\
$(dist)/github.min.js\
$(dist)/googlereader.min.js\
$(dist)/instapaper.min.js\
$(dist)/iusethis.min.js\
$(dist)/lastfm.min.js\
$(dist)/mlkshk.min.js\
$(dist)/picplz.min.js\
$(dist)/pinboard.min.js\
$(dist)/posterous.min.js\
$(dist)/reddit.min.js\
$(dist)/slideshare.min.js\
$(dist)/stackoverflow.min.js\
$(dist)/tumblr.min.js\
$(dist)/twitter.min.js\
$(dist)/vimeo.min.js\
$(dist)/wordpress.min.js\
$(dist)/youtube.min.js 
 
all: uncompressed compressed serviceList

uncompressed: $(jls)

$(jls): $(modules)
	cat $^ > $@
	
compressed: $(jlsMin)

# jlsMin is the concatenation of the minified modules
# TODO: Use implicit and pattern rules
#$(jlsMin): $(minifiedModules)
#$(dist)/%.min.js: $(servicesDir)/%.js
#	uglifyjs $^
#$(jlsMin): $(dist)/core.min.js $(dist)/blogger.min.js $(dist)/dailymotion.min.js
$(jlsMin): $(minifiedModules)
	cat $^ > $@

$(dist)/core.min.js: $(srcPath)/core.js
	uglifyjs $(uglifyOpts) $^ > $@
	
$(dist)/blogger.min.js: $(servicesDir)/blogger.js
	uglify $(uglifyOpts) $^ > $@

$(dist)/dailymotion.min.js: $(servicesDir)/dailymotion.js
	uglify $(uglifyOpts) $^ > $@
	
$(dist)/delicious.min.js: $(servicesDir)/delicious.js
	uglify $(uglifyOpts) $^ > $@
	
$(dist)/deviantart.min.js: $(servicesDir)/deviantart.js
	uglify $(uglifyOpts) $^ > $@
	
$(dist)/dribbble.min.js: $(servicesDir)/dribbble.js
	uglify $(uglifyOpts) $^ > $@

$(dist)/flickr.min.js: $(servicesDir)/flickr.js
	uglify $(uglifyOpts) $^ > $@

$(dist)/foomark.min.js: $(servicesDir)/foomark.js
	uglify $(uglifyOpts) $^ > $@

$(dist)/formspring.min.js: $(servicesDir)/formspring.js
	uglify $(uglifyOpts) $^ > $@

$(dist)/forrst.min.js: $(servicesDir)/forrst.js
	uglify $(uglifyOpts) $^ > $@

$(dist)/foursquare.min.js: $(servicesDir)/foursquare.js
	uglify $(uglifyOpts) $^ > $@

$(dist)/github.min.js: $(servicesDir)/github.js
	uglify $(uglifyOpts) $^ > $@

$(dist)/googlereader.min.js: $(servicesDir)/googlereader.js
	uglify $(uglifyOpts) $^ > $@

$(dist)/instapaper.min.js: $(servicesDir)/instapaper.js
	uglify $(uglifyOpts) $^ > $@

$(dist)/iusethis.min.js: $(servicesDir)/iusethis.js
	uglify $(uglifyOpts) $^ > $@

$(dist)/lastfm.min.js: $(servicesDir)/lastfm.js
	uglify $(uglifyOpts) $^ > $@

$(dist)/mlkshk.min.js: $(servicesDir)/mlkshk.js
	uglify $(uglifyOpts) $^ > $@
	
$(dist)/picplz.min.js: $(servicesDir)/picplz.js
	uglify $(uglifyOpts) $^ > $@
	
$(dist)/pinboard.min.js: $(servicesDir)/pinboard.js
	uglify $(uglifyOpts) $^ > $@
	
$(dist)/posterous.min.js: $(servicesDir)/posterous.js
	uglify $(uglifyOpts) $^ > $@
	
$(dist)/reddit.min.js: $(servicesDir)/reddit.js
	uglify $(uglifyOpts) $^ > $@
	
$(dist)/slideshare.min.js: $(servicesDir)/slideshare.js
	uglify $(uglifyOpts) $^ > $@
	
$(dist)/stackoverflow.min.js: $(servicesDir)/stackoverflow.js
	uglify $(uglifyOpts) $^ > $@
	
$(dist)/tumblr.min.js: $(servicesDir)/tumblr.js
	uglify $(uglifyOpts) $^ > $@
	
$(dist)/twitter.min.js: $(servicesDir)/twitter.js
	uglify $(uglifyOpts) $^ > $@
	
$(dist)/vimeo.min.js: $(servicesDir)/vimeo.js
	uglify $(uglifyOpts) $^ > $@
	
$(dist)/wordpress.min.js: $(servicesDir)/wordpress.js
	uglify $(uglifyOpts) $^ > $@
	
$(dist)/youtube.min.js: $(servicesDir)/youtube.js
	uglify $(uglifyOpts) $^ > $@
	
serviceList:
#	grep -l $.fn.lifestream.feeds. $(servicesDir)/*.js
#	ls -l $(servicesDir) | awk '{print $$NF}'
#	ls -l $(servicesDir) | awk '{print $$9}'
#	ls -l $(servicesDir) | grep -v '^total' | awk '{print $$9}' 
#	find $(servicesDir) -name '*.js' -exec echo '{}' \;
	ls -l $(servicesDir) | grep -v '^total' | awk '{print $$9}' | sed 's;\(.*\)\.js;\1;' > $(serviceListPath)

clean: 
	rm $(dist)/*
	
printVars:
	@echo $(srcPath)
	@echo $(modules)
	@echo $(servicesDir)
	@echo $(buildDir)
	
.PHONY: all compressed uncompressed serviceList printVars