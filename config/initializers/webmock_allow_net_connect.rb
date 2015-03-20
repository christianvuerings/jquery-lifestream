Rails.application.config.after_initialize do
  if defined? WebMock
    WebMock.allow_net_connect!
  end
end
