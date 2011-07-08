srcPath = ../src
servicesDir = $(srcPath)/services
buildDir = .
dist = ../dist
modules = $(srcPath)/core.js $(servicesDir)/*.js
serviceListPath = ../download/services.txt
jls = $(dist)/jquery.lifestream.js

all: $(jls) serviceList

$(jls): $(modules)
	cat $^ > $@

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