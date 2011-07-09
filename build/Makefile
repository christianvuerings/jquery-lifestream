srcPath = ../src
servicesDir = $(srcPath)/services
buildDir = .
dist = ../dist
modules = $(srcPath)/core.js $(servicesDir)/*.js
serviceListPath = ../download/services.txt
jls = $(dist)/jquery.lifestream.js
jlsMin = $(dist)/jquery.lifestream.min.js
# minifiedModules = $(dist)/*.min.js
#minifiedServiceModules := $(patsubst %.js,%.min.js,$(wildcard $(servicesDir)/*.js))
minifiedModules = $(dist)/core.min.js\
$(dist)/blogger.min.js\
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
	uglifyjs $^ > $@
	
$(dist)/blogger.min.js: $(servicesDir)/blogger.js
	uglifyjs $^ > $@

$(dist)/dailymotion.min.js: $(servicesDir)/dailymotion.js
	uglifyjs $^ > $@
	
$(dist)/delicious.min.js: $(servicesDir)/delicious.js
	uglifyjs $^ > $@
	
$(dist)/deviantart.min.js: $(servicesDir)/deviantart.js
	uglifyjs $^ > $@
	
$(dist)/dribbble.min.js: $(servicesDir)/dribbble.js
	uglifyjs $^ > $@

$(dist)/flickr.min.js: $(servicesDir)/flickr.js
	uglifyjs $^ > $@

$(dist)/foomark.min.js: $(servicesDir)/foomark.js
	uglifyjs $^ > $@

$(dist)/formspring.min.js: $(servicesDir)/formspring.js
	uglifyjs $^ > $@

$(dist)/forrst.min.js: $(servicesDir)/forrst.js
	uglifyjs $^ > $@

$(dist)/foursquare.min.js: $(servicesDir)/foursquare.js
	uglifyjs $^ > $@

$(dist)/github.min.js: $(servicesDir)/github.js
	uglifyjs $^ > $@

$(dist)/googlereader.min.js: $(servicesDir)/googlereader.js
	uglifyjs $^ > $@

$(dist)/instapaper.min.js: $(servicesDir)/instapaper.js
	uglifyjs $^ > $@

$(dist)/iusethis.min.js: $(servicesDir)/iusethis.js
	uglifyjs $^ > $@

$(dist)/lastfm.min.js: $(servicesDir)/lastfm.js
	uglifyjs $^ > $@

$(dist)/mlkshk.min.js: $(servicesDir)/mlkshk.js
	uglifyjs $^ > $@
	
$(dist)/picplz.min.js: $(servicesDir)/picplz.js
	uglifyjs $^ > $@
	
$(dist)/pinboard.min.js: $(servicesDir)/pinboard.js
	uglifyjs $^ > $@
	
$(dist)/posterous.min.js: $(servicesDir)/posterous.js
	uglifyjs $^ > $@
	
$(dist)/reddit.min.js: $(servicesDir)/reddit.js
	uglifyjs $^ > $@
	
$(dist)/slideshare.min.js: $(servicesDir)/slideshare.js
	uglifyjs $^ > $@
	
$(dist)/stackoverflow.min.js: $(servicesDir)/stackoverflow.js
	uglifyjs $^ > $@
	
$(dist)/tumblr.min.js: $(servicesDir)/tumblr.js
	uglifyjs $^ > $@
	
$(dist)/twitter.min.js: $(servicesDir)/twitter.js
	uglifyjs $^ > $@
	
$(dist)/vimeo.min.js: $(servicesDir)/vimeo.js
	uglifyjs $^ > $@
	
$(dist)/wordpress.min.js: $(servicesDir)/wordpress.js
	uglifyjs $^ > $@
	
$(dist)/youtube.min.js: $(servicesDir)/youtube.js
	uglifyjs $^ > $@
	
serviceList:
#	grep -l $.fn.lifestream.feeds. $(servicesDir)/*.js
#	ls -l $(servicesDir) | awk '{print $$NF}'
#	ls -l $(servicesDir) | awk '{print $$9}'
#	ls -l $(servicesDir) | grep -v '^total' | awk '{print $$9}' 
#	find $(servicesDir) -name '*.js' -exec echo '{}' \;
	ls -l $(servicesDir) | grep -v '^total' | awk '{print $$9}' | sed 's;\(.*\)\.js;\1;' > $(serviceListPath)

printVars:
	@echo $(srcPath)
	@echo $(modules)
	@echo $(servicesDir)
	@echo $(buildDir)
	
.PHONY: all compressed uncompressed serviceList printVars