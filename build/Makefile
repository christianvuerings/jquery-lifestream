src = ../src
services = $(src)/services
build = .
main = ..
modules = $(src)/core.js $(services)/*.js
service_list = ../download/services.json
jls = $(main)/jquery.lifestream.js
jls_min = $(main)/jquery.lifestream.min.js
uglifyjs = ../download/js/uglifyjs-cs.js
uglifyjs_min = ../download/js/uglifyjs-cs.min.js
script = ../download/js/script.js
script_min = ../download/js/script.min.js

.PHONY: all jls jls-min uglifyjs uglifyjs-min service-list script-min

all: jls jls-min uglifyjs uglifyjs-min service-list script-min

jls: $(jls)
	
jls-min: $(jls_min)
	
uglifyjs: $(uglifyjs)
	
uglifyjs-min: $(uglifyjs_min)
	
script-min: $(script_min)
	
service-list:
	@echo "Building $(service_list)"
	@node service-list.js $(services) > $(service_list)
	
$(jls): $(modules) | $(main)
	@echo "Building $@"
	@cat $^ > $@

$(jls_min): $(jls)
	@echo "Building $@"
	@uglifyjs $^ > $@
	
$(uglifyjs): uglifyjs-cs-prologue.js parse-js-prologue.js parse-js.js \
parse-js-epilogue.js process-prologue.js process.js process-epilogue.js \
squeeze-more-prologue.js squeeze-more.js squeeze-more-epilogue.js \
uglifyjs-cs-epilogue.js
	@echo "Building $@"
	@cat $^ > $@

$(uglifyjs_min): $(uglifyjs)
	@echo "Building $@"
	@uglifyjs $^ > $@
	
$(script_min): $(script)
	@echo "Building $@"
	@uglifyjs $^ > $@