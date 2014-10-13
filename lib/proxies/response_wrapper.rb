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
    if e.is_a?(Errors::ProxyError)
      log_message = e.log_message
      response = e.response
      if e.wrapped_exception
        log_message += " #{e.wrapped_exception.class} #{e.wrapped_exception.message}."
      end
    else
      log_message = " #{e.class} #{e.message}"
      if opts[:return_nil_on_generic_error]
        response = nil
      else
        response = {
          :body => opts[:user_message_on_exception],
          :statusCode => 503
        }
      end
    end
    log_message += " Associated key: #{key}"

    Rails.logger.error(log_message + "\n" + e.backtrace.join("\n "))
    response
  end

end
