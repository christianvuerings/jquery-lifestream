module Financials
  class Proxy < BaseProxy

    include ClassLogger, SafeJsonParser

    APP_ID = "CFV"

    def initialize(options = {})
      super(Settings.financials_proxy, options)
    end

    def get
      self.class.smart_fetch_from_cache({id: @uid, user_message_on_exception: "My Finances is currently unavailable. Please try again later."}) do
        request_internal("/student/#{lookup_student_id}", "financials")
      end
    end

    def request_internal(path, vcr_cassette)
      student_id = lookup_student_id
      if student_id.nil?
        logger.info "Lookup of student_id for uid #@uid failed, cannot call CFV API path #{path}"
        return {
          body: "CalCentral's My Finances tab is only available for current or recent UC Berkeley students. If you are seeing this message, it is because CalCentral did not receive any CARS data for your account. If you believe that you have received this message in error, please use the Feedback link below to tell us about the problem.",
          status_code: 400
        }
      else
        url = "#{Settings.financials_proxy.base_url}#{path}"
        logger.info "Fake = #@fake; Making request to #{url} on behalf of user #{@uid}, student_id = #{student_id}; cache expiration #{self.class.expires_in}"

        response = FakeableProxy.wrap_request(APP_ID + "_" + vcr_cassette, @fake, {match_requests_on: [:method, :path]}) {
          HTTParty.get(
            url,
            digest_auth: {username: Settings.financials_proxy.username, password: Settings.financials_proxy.password},
            timeout: Settings.application.outgoing_http_timeout
          )
        }
        if response.code == 404
          logger.debug "Connection failed: #{response.code} #{response.body}; url = #{url}"
          body = "My Finances did not receive any CARS data for your account. If you are a current or recent student, and you feel that you've received this message in error, please try again later. If you continue to see this error, please use the feedback link below to tell us about the problem."
        elsif response.code >= 400
          body = "My Finances is currently unavailable. Please try again later."
          raise Errors::ProxyError.new("Connection failed: #{response.code} #{response.body}; url = #{url}", {
            body: body,
            status_code: response.code
          })
        else
          body = safe_json(response.body)
        end

        # VCR mangles the x_cfv_api_version header to x-cfv-api-version when replaying in fake mode.
        api_version = nil
        version_header = (@fake ? "x-cfv-api-version" : "x_cfv_api_version")
        if response.headers && response.headers[version_header]
          version = response.headers[version_header]
          api_version = (version.is_a?(Array) ? version[0] : version)
        end

        logger.debug "Remote server status #{response.code}; url = #{url}"
        return {
          body: body,
          status_code: response.code,
          apiVersion: api_version
        }
      end
    end
  end
end
