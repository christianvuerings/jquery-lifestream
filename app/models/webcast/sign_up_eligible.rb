module Webcast
  class SignUpEligible < Proxy

    def initialize(options = {})
      super(options)
      @options = options
    end

    def get_json_path
      'eligible-for-webcast.json'
    end

    def request_internal
      is_webcast_sign_up_active = Webcast::SystemStatus.new(@options).get['is_sign_up_active']
      logger.info "Webcast sign-up period #{is_webcast_sign_up_active ? 'is' : 'is not'} active."
      return {} unless Settings.features.videos && is_webcast_sign_up_active
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
