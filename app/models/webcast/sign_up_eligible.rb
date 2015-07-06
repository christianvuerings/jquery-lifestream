module Webcast
  class SignUpEligible < Proxy

    def initialize(options = {})
      super(options)
      @options = options
    end

    def get_json_path
      'warehouse/eligible-for-webcast.json'
    end

    def request_internal
      return {} unless Settings.features.videos
      data = get_json_data
      ccn_set_by_term = {}
      semesters = data['semesters']
      semesters.each { |s| ccn_set_by_term["#{s['semester'].downcase}-#{s['year']}"] = s['ccnSet'].to_a } if semesters
      ccn_set_by_term
    end

  end
end
