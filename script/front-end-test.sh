npm -g install jshint
# Version 1.8.0 of jscs incorrectly flags indented parameter lists as
# "Missing space before function parameter".
npm -g install jscs@1.7.3
gem install scss-lint
scss-lint app/assets/stylesheets/
[[ $? -ne 0 ]] && echo 'scss-lint failed' && exit 1 || echo 'scss-lint was succesful'
