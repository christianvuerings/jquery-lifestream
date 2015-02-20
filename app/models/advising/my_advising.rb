module Advising
  class MyAdvising < UserSpecificModel
    include Cache::LiveUpdatesEnabled
    include Cache::FeedExceptionsHandled
    include HttpRequester
    include SafeJsonParser
    include User::Student
    include ClassLogger

    def initialize(uid, options={})
      super(uid, options)
      @settings = Settings.advising_proxy
      @fake = (options[:fake] != nil) ? options[:fake] : @settings.fake
    end

    def default_message_on_exception
      'Failed to connect with your department\'s advising system.'
    end

    def get_feed_internal
      if Settings.features.advising
        get_parsed_response
      else
        {}
      end
    end

    def get_parsed_response
      student_id = lookup_student_id
      if student_id.blank?
        # don't continue if student id can't be found.
        logger.info "Lookup of student_id for uid #@uid failed, cannot call Advising API"
        return {}
      end

      if @fake
        logger.info "Fake = #@fake, getting data from JSON fixture file; user #{@uid}; cache expiration #{self.class.expires_in}"
        json = File.read(Rails.root.join('fixtures', 'json', 'advising.json').to_s)
        parsed_json = safe_json(json)
        status_code = 200
      else
        url = "#{@settings.base_url}/student/#{student_id}"
        logger.info "Internal_get: Fake = #@fake; Making request to #{url} on behalf of user #{@uid}; cache expiration #{self.class.expires_in}"
        response = get_response(
          url,
          basic_auth: {username: @settings.username, password: @settings.password},
          on_error: {rescue_status: 404}
        )
        status_code = response.code
        if status_code == 404
          logger.debug "404 response from advising API for user #{@uid}"
          parsed_json = {'body' => 'No advising data could be found for your account.'}
        else
          unless (parsed_json = safe_json(response.body))
            raise Errors::ProxyError.new('Empty response', response: response, url: url, uid: uid)
          end
        end
        logger.debug "Advising remote response: #{response.inspect}"
      end

      HashConverter.camelize(parsed_json).merge(statusCode: status_code)
    end

  end
end
