class BlogFeedController < ApplicationController

  def get_blog_info
    result = {}
    if Settings.features.service_alerts_rss
      alert_data = EtsBlog::ServiceAlerts.new.get_latest
    else
      alert_data = EtsBlog::Alerts.new.get_latest
    end
    result.merge!(:alert => alert_data) unless alert_data.blank?
    result.merge!(:releaseNote => EtsBlog::ReleaseNotes.new.get_latest )
    render :json => result
  end
end
