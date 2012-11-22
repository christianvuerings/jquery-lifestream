# Webmock is enabled by default upon load (and is only loaded in the test & testext group)
# This causes issues with test utilities, like Selenium. It should then be enabled when
# the backend rspec test run.
if !(ENV['RAILS_ENV'] =~ (/(test|testext)$/)).nil?
  require 'webmock'
  WebMock.disable!
end