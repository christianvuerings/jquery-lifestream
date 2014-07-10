if Settings.logger.proxy_threshold_in_ms > 0
  Rails.logger.warn "Logging all proxies slower than #{Settings.logger.proxy_threshold_in_ms.to_i}ms"
  ActiveSupport::Notifications.subscribe  'proxy' do |name, start, finish, id, payload|
    duration = (finish - start)*1000.0
    if duration > Settings.logger.proxy_threshold_in_ms.to_i
      Rails.logger.error "SLOW PROXY duration: #{duration.to_i}ms  #{payload.inspect} "
    end
  end
end
