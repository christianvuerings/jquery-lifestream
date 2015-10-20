module CampusSolutions
  class DashboardUrl < DirectProxy

    def initialize(options = {})
      super options
      initialize_mocks if @fake
    end

    def xml_filename
      'dashboard_url.xml'
    end

    def build_feed(response)
      return {} if response.parsed_response.blank?
      feed = response.parsed_response
      {
        url: feed['UC_CC_COMM_DB_URL_GET']['DASHBOARD_URL']['URL'].strip
      }
    end

    def url
      "#{@settings.base_url}/UC_CC_COMM_DB_URL.v1/dashboard/url/"
    end

    def is_feature_enabled
      Settings.features.show_notifications_archive_link
    end

  end
end
