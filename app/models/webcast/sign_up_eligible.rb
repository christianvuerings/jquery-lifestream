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
      ccn_set_by_term = {}
      data = get_json_data
      data['semesters'].each do |term|
        slug = "#{term['semester'].downcase}-#{term['year']}"
        ccn_set_by_term[slug] = term['ccnSet'].to_a
      end
      ccn_set_by_term
    end

  end
end
