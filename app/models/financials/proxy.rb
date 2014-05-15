module Financials
  # This Proxy class gets data from the external CFV HTTP service.
  class Proxy < BaseProxy

    include ClassLogger, SafeJsonParser
    include Cache::UserCacheExpiry

    # APP_ID must be unique within the system, and is used by VCR and the front-end in various ways.
    APP_ID = 'CFV'

    def initialize(options = {})
      super(Settings.financials_proxy, options)
    end

    def get
      # smart_fetch_from_cache provides helpful services like writing only successful entries to the cache.
      self.class.smart_fetch_from_cache({id: @uid, user_message_on_exception: 'My Finances is currently unavailable. Please try again later.'}) do
        request_internal('financials')
      end
    end

    private

    def request_internal(vcr_cassette)
      # not all external data sources need a student id, but this one does.
      student_id = lookup_student_id
      if student_id.blank?
        # don't continue if student id can't be found.
        logger.info "Lookup of student_id for uid #@uid failed, cannot call CFV API"
        {
          body: "CalCentral's My Finances tab provides financial data for current students and recent graduates. You are seeing this message because we do not have CARS billing data for your account. If you believe that you have received this message in error, please report the problem using the Feedback link below.",
          statusCode: 400
        }
      else
        url = "#{Settings.financials_proxy.base_url}/student/#{student_id}"
        logger.info "Fake = #@fake; Making request to #{url} on behalf of user #{@uid}, student_id = #{student_id}; cache expiration #{self.class.expires_in}"

        # HTTParty is our preferred HTTP library. FakeableProxy provides the (deprecated) VCR response recording system.
        response = FakeableProxy.wrap_request(APP_ID + "_" + vcr_cassette, @fake, {match_requests_on: [:method, :path]}) {
          HTTParty.get(
            url,
            digest_auth: {username: Settings.financials_proxy.username, password: Settings.financials_proxy.password},
            timeout: Settings.application.outgoing_http_timeout
          )
        }

        # handle errors that we expect, like 404s and 500s, with a helpful error message.
        # raising a ProxyError will make smart_fetch_from_cache skip writing to the cache.
        # if an error might heal itself the next time the proxy is called, that's what you
        # want to do. Otherwise, if you want to cache error states for a long time, just return
        # the error in the proxy body.
        if response.code == 404
          logger.debug "Connection failed: #{response.code} #{response.body}; url = #{url}"
          body = "My Finances did not receive any CARS data for your account. If you are a current or recent student, and you feel that you've received this message in error, please try again later. If you continue to see this error, please use the feedback link below to tell us about the problem."
        elsif response.code >= 400
          body = 'My Finances is currently unavailable. Please try again later.'
          raise Errors::ProxyError.new("Connection failed: #{response.code} #{response.body}; url = #{url}", {
            body: body,
            statusCode: response.code
          })
        else
          body = safe_json(response.body)
        end

        # CFV API sends its version number in an HTTP header. We use this on the front end in various ways.
        # VCR mangles the x_cfv_api_version header to x-cfv-api-version when replaying in fake mode.
        api_version = nil
        version_header = (@fake ? "x-cfv-api-version" : "x_cfv_api_version")
        if response.headers && response.headers[version_header]
          version = response.headers[version_header]
          api_version = (version.is_a?(Array) ? version[0] : version)
        end

        logger.debug "Remote server status #{response.code}; url = #{url}"
        {
          body: body,
          statusCode: response.code,
          apiVersion: api_version
        }
      end
    end
  end
end
