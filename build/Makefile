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
	@echo "$(service_list) build complete"
	
$(jls): $(modules) | $(main)
	@cat $^ > $@

$(jls_min): $(jls)
	@uglifyjs $^ > $@
	
$(uglifyjs): uglifyjs-cs-prologue.js parse-js-prologue.js parse-js.js \
parse-js-epilogue.js process-prologue.js process.js process-epilogue.js \
squeeze-more-prologue.js squeeze-more.js squeeze-more-epilogue.js \
uglifyjs-cs-epilogue.js
	@cat $^ > $@

$(uglifyjs_min): $(uglifyjs)
	@uglifyjs $^ > $@
	
$(script_min): $(script)
	@uglifyjs $^ > $@