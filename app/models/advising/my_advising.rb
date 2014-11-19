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
        begin
          response = get_response(
            url,
            basic_auth: {username: @settings.username, password: @settings.password}
          )
        rescue Timeout::Error
          logger.error("Timeout error: url = #{url}, uid = #{@uid}")
          raise Errors::ProxyError.new
        end
        status_code = response.code
        if response.code >= 400 && response.code != 404
          logger.error("Connection failed: #{response.code} #{response.body}; url = #{url}, uid = #{@uid}")
          raise Errors::ProxyError.new
        elsif response.code == 404
          logger.debug "404 response from advising API for user #{@uid}"
          parsed_json = {'body' => 'No advising data could be found for your account.'}
        else
          unless (parsed_json = safe_json(response.body))
            logger.error("Empty response: #{response.code} #{response.body}; url = #{url}, uid = #{@uid}")
            raise Errors::ProxyError.new
          end
        end
        logger.debug "Advising remote response: #{response.inspect}"
      end

      {
        statusCode: status_code
      }.merge(HashConverter.camelize(parsed_json))
    end

  end
end
