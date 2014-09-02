module Finaid
  class Proxy < BaseProxy

    include ClassLogger
    include User::Student

    APP_ID = "Myfinaid"

    attr_reader :term_year

    def initialize(options = {})
      super(Settings.myfinaid_proxy, options)
      raise ArgumentError, "Finaid::Proxy requires a term_year" unless options[:term_year].present?
      @term_year = options[:term_year].to_s
    end

    def get
      request_internal("myfinaid")
    end

    def request_internal(vcr_cassette, params = {})
      student_id = lookup_student_id
      if student_id.nil?
        logger.info "Lookup of student_id for uid #@uid failed, cannot call Myfinaid API"
        return {
          :body => "Lookup of student_id for uid #@uid failed, cannot call Myfinaid API",
          :statusCode => 400
        }
      else
        url = "#{@settings.base_url}/#{student_id}/finaid"
        vcr_opts = {:match_requests_on => [:method, :path, VCR.request_matchers.uri_without_params(:token, :app_id, :app_key)]}
        logger.info "Fake = #@fake; Making request to #{url} on behalf of user #{@uid}, student_id = #{student_id}, aidYear = #{@term_year}; cache expiration #{self.class.expires_in}"
        response = FakeableProxy.wrap_request(vcr_id = APP_ID + "_" + vcr_cassette, @fake, vcr_opts) {
          query_params = {
            token: @settings.token,
            aidYear: @term_year
          }
          if (@settings.app_id.present? && @settings.app_key.present?)
            query_params.merge!({app_id: @settings.app_id,
                                 app_key: @settings.app_key, })
          end

          get_response(
            url,
            query: params.merge(query_params)
          )
        }
        if response.code >= 400
          raise Errors::ProxyError.new("Connection failed: #{response.code} #{response.body}", nil)
        end
        logger.debug "Remote server status #{response.code}, Body = #{response.body}"
        return {
          :body => response.body,
          :statusCode => response.code
        }
      end
    end

  end
end
