src = ../src
services = $(src)/services
build = .
dist = ../dist
modules = $(src)/core.js $(services)/*.js
service_list = ../download/services.json
jls = $(dist)/jquery.lifestream.js
jls_min = $(dist)/jquery.lifestream.min.js
uglifyjs = ../download/js/uglifyjs-cs.js
uglifyjs_min = ../download/js/uglifyjs-cs.min.js
script = ../download/js/script.js
script_min = ../download/js/script.min.js

.PHONY: all jls jls-min uglifyjs uglifyjs-min service-list empty-dist \
script-min

all: jls jls-min uglifyjs uglifyjs-min service-list script-min
jls: $(jls)
	@echo "$^ build complete"
jls-min: $(jls_min)
	@echo "$^ build complete"
uglifyjs: $(uglifyjs)
	@echo "$^ build complete"
uglifyjs-min: $(uglifyjs_min)
	@echo "$^ build complete"
script-min: $(script_min)
	@echo "$^ build complete"
service-list:
	@node service-list.js $(services) > $(service_list)
#	grep -l $.fn.lifestream.feeds. $(services)/*.js
#	ls -l $(services) | awk '{print $$NF}'
#	ls -l $(services) | awk '{print $$9}'
#	ls -l $(services) | grep -v '^total' | awk '{print $$9}' 
#	find $(services) -name '*.js' -exec echo '{}' \;
#	We used this: @ls -l $(services) | grep -v '^total' | awk '{print $$9}' | sed 's;\(.*\)\.js;\1;' > $(service_list)
	@echo "$(service_list) build complete"
	
$(jls): $(modules) | $(dist)
	@cat $^ > $@

$(jls_min): $(jls)
	@uglifyjs $^ > $@
	
$(uglifyjs): $(build)/parse-js.js $(build)/process.js $(build)/squeeze-more.js
	@cat uglifyjs-cs-prologue.js \
	parse-js-prologue.js \
	parse-js.js \
	parse-js-epilogue.js \
	process-prologue.js \
	process.js \
	process-epilogue.js \
	squeeze-more-prologue.js \
	squeeze-more.js \
	squeeze-more-epilogue.js \
	uglifyjs-cs-epilogue.js \
	> $@
	
$(uglifyjs_min): $(uglifyjs)
	@uglifyjs $^ > $@
  
$(script_min): $(script)
	@uglifyjs $^ > $@
	
$(dist): 
	@mkdir -p $(dist)

empty-dist: 
	@rm $(dist)/*
