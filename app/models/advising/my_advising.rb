module Advising
  class MyAdvising < UserSpecificModel
    include Cache::LiveUpdatesEnabled
    include Cache::FeedExceptionsHandled
    include HttpRequester
    include Proxies::Mockable
    include SafeJsonParser
    include User::Student
    include ClassLogger

    def initialize(uid, options={})
      super(uid, options)
      @settings = Settings.advising_proxy
      @fake = (options[:fake] != nil) ? options[:fake] : @settings.fake
      initialize_mocks if @fake
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
        logger.info "Lookup of student_id for uid #{@uid} failed, cannot call Advising API"
        return {}
      end

      url = "#{@settings.base_url}/student/#{student_id}"
      logger.info "get_parsed_response: Fake = #{@fake}; Making request to #{url} on behalf of user #{@uid}; cache expiration #{self.class.expires_in}"
      response = get_response(
        url,
        basic_auth: {username: @settings.username, password: @settings.password},
        on_error: {rescue_status: 404}
      )
      if response.code == 404
        logger.debug "404 response from advising API for user #{@uid}"
        parsed_json = {'body' => 'No advising data could be found for your account.'}
      else
        unless (parsed_json = safe_json(response.body))
          raise Errors::ProxyError.new('Empty response', response: response, url: url, uid: uid)
        end
      end
      logger.debug "Advising remote response: #{response.inspect}"

      sanitize_response(parsed_json).merge(statusCode: response.code)
    end

    def sanitize_response(response)
      appt_keys = %w|pastAppointments futureAppointments|
      appt_keys.each do |key|
        if response[key]
          response[key].select!{ |appt| valid_appointment? appt }
          response[key].sort_by!{ |appt| appt['dateTime'] }
          response[key].reverse! if key == 'pastAppointments'
        end
      end
      response['caseloadAdvisor'] = response.delete 'caseloadAdviser'
      HashConverter.camelize response
    end

    def valid_appointment?(appt)
      if appt['dateTime'].present? &&
        appt['urlToEditAppointment'].present? &&
        (appt['location'].present? || appt['method'].present?) &&
        (appt['staff'].is_a?(Hash) && appt['staff']['name'].present?)
        true
      else
        logger.warn "Received invalid appointment data for user #{@uid}: #{appt}"
        false
      end
    end

    def mock_json
      read_file('fixtures', 'json', 'advising.json')
    end

  end
end
