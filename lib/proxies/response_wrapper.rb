module ResponseWrapper

  def handling_exceptions(key, opts={}, &block)
    opts[:user_message_on_exception] ||= "An unknown server error occurred"
    begin
      exception = nil
      entry = block.call
    rescue => e
      exception = e
      entry = handle_exception(e, key, opts)
    end
    entry = entry.to_json if opts[:jsonify]
    {
      response: entry,
      exception: exception
    }
  end

  # When an exception occurs, log an error and return the body with error info.
  def handle_exception(e, key, opts)
    if e.is_a? Errors::ProxyError
      response = e.response || default_response(opts)
      log_message = e.log_message || ''
      log_message += "; #{e.wrapped_exception.class} #{e.wrapped_exception.message}" if e.wrapped_exception
      log_message += "; url: #{e.url}" if e.url
      log_message += "; status: #{e.status}" if e.status
    else
      response = default_response(opts)
      log_message = "#{e.class} #{e.message}"
    end
    log_message += "\nAssociated key: #{key}"
    if e.is_a?(Errors::ProxyError)
      log_message += "; uid: #{e.uid}" if e.uid
      log_message += ". Response body: #{e.body}" if e.body
    end
    log_message += "\n" + e.backtrace.join("\n ")
    Rails.logger.error(log_message)
    response
  end

  def default_response(opts)
    if opts[:return_nil_on_generic_error]
      nil
    else
      {
        :body => opts[:user_message_on_exception],
        :statusCode => 503
      }
    end
  end


end
