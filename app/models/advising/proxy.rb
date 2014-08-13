module Advising
  class Proxy < BaseProxy

    include SafeJsonParser
    include ClassLogger
    include User::Student
    include Cache::UserCacheExpiry

    APP_ID = 'Advising'

    def initialize(options = {})
      super(Settings.advising_proxy, options)
    end

    def get
      self.class.smart_fetch_from_cache({id: @uid, user_message_on_exception: 'An error occurred retrieving data for Advisor Appointments. Please try again later.'}) do
        internal_get
      end
    end

    private

    def internal_get
      return {} unless Settings.features.advising
      student_id = lookup_student_id
      if student_id.blank?
        # don't continue if student id can't be found.
        logger.info "Lookup of student_id for uid #@uid failed, cannot call Advising API"
        return {}
      end

      if @fake
        logger.info "Fake = #@fake, getting data from JSON fixture file; user #{@uid}; cache expiration #{self.class.expires_in}"
        json = File.read(Rails.root.join('fixtures', 'json', 'advising.json').to_s)
      else
        url = "#{@settings.base_url}/student/#{student_id}"
        logger.info "Internal_get: Fake = #@fake; Making request to #{url} on behalf of user #{@uid}; cache expiration #{self.class.expires_in}"
        response = ActiveSupport::Notifications.instrument('proxy', {url: url, class: self.class}) do
          HTTParty.get(
            url,
            basic_auth: {username: @settings.username, password: @settings.password},
            timeout: Settings.application.outgoing_http_timeout,
            verify: Settings.application.layer == 'production'
          )
        end
        if response.code >= 400
          raise Errors::ProxyError.new("Connection failed: #{response.code} #{response.body}; url = #{url}", {
            body: 'An error occurred retrieving data for Advisor Appointments. Please try again later.',
            statusCode: response.code
          })
        else
          json = response.body
        end
        logger.debug "Advising remote response: #{response.inspect}"
      end
      {
        statusCode: 200
      }.merge(HashConverter.camelize(safe_json(json)))
    end

  end
end
