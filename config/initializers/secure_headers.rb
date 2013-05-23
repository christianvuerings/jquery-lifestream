# Configuration for the secure_headers gem, which sets X-Frame and CSP headers.
# Docs at http://rubydoc.info/gems/secure_headers/0.5.0/frames
# Rails 4 will DENY X-Frame by default

module Calcentral
  class Application < Rails::Application
    config.before_initialize do
      ::SecureHeaders::Configuration.configure do |config|
        config.x_frame_options = 'DENY'
      end

    end
  end
end
