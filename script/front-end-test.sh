npm install
gem install scss-lint --version 0.31.0
scss-lint app/assets/stylesheets/
[[ $? -ne 0 ]] && echo 'scss-lint failed' && exit 1 || echo 'scss-lint was succesful'
