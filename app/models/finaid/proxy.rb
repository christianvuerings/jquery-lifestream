module Finaid
  class Proxy < BaseProxy
    include ClassLogger
    include Proxies::MockableXml
    include User::Student

    attr_reader :term_year

    def initialize(options = {})
      super(Settings.myfinaid_proxy, options)
      raise ArgumentError, "Finaid::Proxy requires a term_year" unless options[:term_year].present?
      @term_year = options[:term_year].to_s
      @student_id = lookup_student_id
      initialize_mocks if @fake
    end

    def get
      FeedWrapper.new request_internal
    end

    private

    def mock_request
      super.merge(uri_matching: request_url, query_including: {aidYear: @term_year})
    end

    def mock_xml
      read_file('fixtures', 'xml', "finaid_#{@student_id}_#{@term_year}.xml")
    end

    def request_internal
      if @student_id.nil?
        logger.info "Lookup of student_id for uid #{@uid} failed, cannot call Finaid API"
        return nil
      else
        logger.info "Fake = #{@fake}; Making request to #{request_url} on behalf of user #{@uid}, student_id = #{@student_id}, aidYear = #{@term_year}; cache expiration #{self.class.expires_in}"
        request_options = {
          query: {aidYear: @term_year}
        }
        if (@settings.app_id.present? && @settings.app_key.present?)
          request_options[:headers] = {
            'app_id' => @settings.app_id,
            'app_key' => @settings.app_key
          }
        end
        response = get_response(request_url, request_options)
        logger.debug "Remote server status #{response.code}, Body = #{response.body}"
        response
      end
    end

    def request_url
      "#{@settings.base_url}/#{@student_id}/finaid"
    end

  end
end
