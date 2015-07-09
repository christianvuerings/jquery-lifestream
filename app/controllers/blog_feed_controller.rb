class BlogFeedController < ApplicationController

  def get_blog_info
    result = {}
    alert_data = EtsBlog::Alerts.new.get_latest
    result.merge!(:alert => alert_data) unless alert_data.blank?
    result.merge!(:release_note => EtsBlog::ReleaseNotes.new.get_latest )
    render :json => result
  end
end
