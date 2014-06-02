if Settings.logger.slow_request_threshold_in_ms.to_i > 0
  Rails.logger.warn "Logging all requests slower than #{Settings.logger.slow_request_threshold_in_ms.to_i}ms"
  ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, finish, id, payload|
    duration = (finish - start) * 1000
    view_time = 0
    db_time = 0
    unless payload[:view_runtime].nil?
      view_time = payload[:view_runtime]
    end
    unless payload[:db_runtime].nil?
      db_time = payload[:db_runtime]
    end

    if duration > Settings.logger.slow_request_threshold_in_ms.to_i
      Rails.logger.error "SLOW PROXY #{payload[:path]}; view=#{view_time.to_i}ms db=#{db_time.to_i}ms total=#{duration.to_i}ms"
    end
  end
end
