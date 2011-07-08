srcPath = ../src
servicesDir = $(srcPath)/services
buildDir = .
dist = ../dist
modules = $(srcPath)/core.js $(servicesDir)/*.js
serviceListPath = ../download/services.txt
jls = $(dist)/jquery.lifestream.js
jlsMin = $(dist)/jquery.lifestream.min.js

all: $(jls) $(jlsMin) serviceList

$(jls): $(modules)
	cat $^ > $@
	
$(jlsMin): $(dist)/*.min.js
	@echo Concatenation of $(jlsMin)
	
$(dist)/%.min.js: $(servicesDir)/%.js
	@echo $^

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