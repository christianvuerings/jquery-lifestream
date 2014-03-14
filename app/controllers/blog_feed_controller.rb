class BlogFeedController < ApplicationController

  caches_action(:get_latest_release_notes, :expires_in => EtsBlog::ReleaseNotes.expires_in)

  def get_blog_info
    result = {}
    if Settings.features.app_alerts
      alert_data = EtsBlog::Alerts.new.get_latest
      result.merge!(:alert => alert_data) unless alert_data.nil?
    end
    result.merge!( EtsBlog::ReleaseNotes.new.get_latest_release_notes )
    render :json => result
  end
end
