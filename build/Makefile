srcPath = ../src
servicesDir = $(srcPath)/services
buildDir = .
dist = ../dist
srcModules = $(srcPath)/core.js $(servicesDir)/*.js
serviceListPath = ../download/services.txt
jls = $(dist)/jquery.lifestream.js
jlsMin = $(dist)/jquery.lifestream.min.js

all: uncompressed compressed serviceList

uncompressed: $(jls)

$(jls): $(srcModules)
	cat $^ > $@
	
compressed: $(jlsMin)

$(jlsMin): $(jls)
	uglifyjs $^ > $@
	
serviceList:
#	grep -l $.fn.lifestream.feeds. $(servicesDir)/*.js
#	ls -l $(servicesDir) | awk '{print $$NF}'
#	ls -l $(servicesDir) | awk '{print $$9}'
#	ls -l $(servicesDir) | grep -v '^total' | awk '{print $$9}' 
#	find $(servicesDir) -name '*.js' -exec echo '{}' \;
	ls -l $(servicesDir) | grep -v '^total' | awk '{print $$9}' | sed 's;\(.*\)\.js;\1;' > $(serviceListPath)
	
../download/js/uglifyjs-cs.js: parse-js.js process.js squeeze-more.js
	cat uglifyjs-cs-prologue.js parse-js-prologue parse-js.js parse-js-epilogue process-prologue process.js process-epilogue squeeze-more-prologue squeeze-more.js squeeze-more-epilogue uglifyjs-cs-epilogue.js

clean: 
	rm $(dist)/*
	
printVars:
	@echo $(srcPath)
	@echo $(srcModules)
	@echo $(servicesDir)
	@echo $(buildDir)
	
.PHONY: all compressed uncompressed serviceList printVars