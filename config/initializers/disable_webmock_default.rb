# Webmock is enabled by default upon load, which causes issues with test utilities,
# like Selenium. It's therefore disabled here and then enabled when
# the backend rspec tests run, and when fake proxies are instantiated in the development
# environment.

if Settings.application.fake_proxies_enabled
  require 'webmock'
  WebMock.disable!
end
