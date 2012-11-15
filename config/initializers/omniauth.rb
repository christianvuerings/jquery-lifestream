Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas, :host => Settings.cas_server
end
