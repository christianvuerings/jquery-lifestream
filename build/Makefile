srcPath = ../src
servicesDir = $(srcPath)/services
buildDir = .
dist = ../dist
srcModules = $(srcPath)/core.js $(servicesDir)/*.js
serviceListPath = ../download/services.txt
jls = $(dist)/jquery.lifestream.js
jlsMin = $(dist)/jquery.lifestream.min.js

all: uncompressed compressed serviceList uglifyjs-cs

$(dist): 
	mkdir -p $(dist)

uncompressed: $(jls)

$(jls): $(srcModules) | $(dist)
	cat $^ > $@
	
compressed: $(jlsMin)

$(jlsMin): $(jls) | $(dist)
	uglifyjs $^ > $@
	
serviceList:
#	grep -l $.fn.lifestream.feeds. $(servicesDir)/*.js
#	ls -l $(servicesDir) | awk '{print $$NF}'
#	ls -l $(servicesDir) | awk '{print $$9}'
#	ls -l $(servicesDir) | grep -v '^total' | awk '{print $$9}' 
#	find $(servicesDir) -name '*.js' -exec echo '{}' \;
	ls -l $(servicesDir) | grep -v '^total' | awk '{print $$9}' | sed 's;\(.*\)\.js;\1;' > $(serviceListPath)
	
uglifyjs-cs: ../download/js/uglifyjs-cs.min.js

../download/js/uglifyjs-cs.min.js: ../download/js/uglifyjs-cs.js
	uglifyjs $^ > $@
	
../download/js/uglifyjs-cs.js: $(buildDir)/parse-js.js $(buildDir)/process.js $(buildDir)/squeeze-more.js
	cat uglifyjs-cs-prologue.js parse-js-prologue.js parse-js.js parse-js-epilogue.js process-prologue.js process.js process-epilogue.js squeeze-more-prologue.js squeeze-more.js squeeze-more-epilogue.js uglifyjs-cs-epilogue.js > $@

clean: 
	rm $(dist)/*
	
printVars:
	@echo $(srcPath)
	@echo $(srcModules)
	@echo $(servicesDir)
	@echo $(buildDir)
	
.PHONY: all compressed uncompressed serviceList printVars