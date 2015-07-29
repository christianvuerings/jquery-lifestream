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
      message_lines = [e.message, "Associated key: #{key}#{e.uid_and_response_body}"]
      response = e.response
    else
      message_lines = ["#{e.class} #{e.message}", "Associated key: #{key}"]
    end
    message_lines << e.backtrace.join("\n ")
    Rails.logger.error message_lines.join("\n")

    response || default_response(opts)
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
