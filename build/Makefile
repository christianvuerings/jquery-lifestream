srcPath = ../src
servicesDir = $(srcPath)/services
modules = $(srcPath)/core.js $(servicesDir)/*.js
buildDir = .

all: serviceList

jquery.lifestream.min.js: $(modules)

serviceList:
#	grep -l $.fn.lifestream.feeds. $(servicesDir)/*.js
#	ls -l $(servicesDir) | awk '{print $$NF}'
#	ls -l $(servicesDir) | awk '{print $$9}'
#	ls -l $(servicesDir) | grep -v '^total' | awk '{print $$9}' 
#	find $(servicesDir) -name '*.js' -exec echo '{}' \;
	ls -l $(servicesDir) | grep -v '^total' | awk '{print $$9}' | sed 's;\(.*\)\.js;\1;' > $(buildDir)/services.txt

printVars:
	@echo $(srcPath)
	@echo $(modules)
	@echo $(servicesDir)
	@echo $(buildDir)