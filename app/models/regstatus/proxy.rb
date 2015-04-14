module Regstatus
  class Proxy < BaseProxy

    include ClassLogger
    include Cache::UserCacheExpiry
    include Proxies::Mockable
    include User::Student

    def initialize(options = {})
      super(Settings.regstatus_proxy, options)
      initialize_mocks if @fake
    end

    def get(term=nil)
      term ||= Berkeley::Terms.fetch.current
      internal_response = self.class.smart_fetch_from_cache(id: "#{@uid}/#{term.slug}") do
        get_internal term
      end
      if internal_response[:noStudentId] || internal_response[:statusCode] < 400
        internal_response
      else
        {
          errored: true
        }
      end
    end

    private

    def get_internal(term)
      student_id = lookup_student_id
      if student_id.nil?
        logger.info "Lookup of student_id for uid #{@uid} failed, cannot call Regstatus API"
        {
          noStudentId: true
        }
      else
        url = @settings.base_url
        logger.info "Fake = #{@fake}; Making request to #{url} on behalf of user #{@uid}, student_id = #{student_id}, term = #{term}; cache expiration #{self.class.expires_in}"
        request_options = {
          query: {
            studentId: student_id,
            termYear: term.year,
            termName: term.name,
            _type: 'json'
          }
        }
        if @settings.app_id.present? && @settings.app_key.present?
          request_options[:headers] = {
            'app_id' => @settings.app_id,
            'app_key' => @settings.app_key
          }
        end
        response = get_response(url, request_options)
        logger.debug "Remote server status #{response.code}, Body = #{response.body}"
        {
          statusCode: response.code,
          feed: response.parsed_response
        }
      end
    end

    def mock_json
      read_file('fixtures', 'json', 'regstatus.json')
    end

  end
end
