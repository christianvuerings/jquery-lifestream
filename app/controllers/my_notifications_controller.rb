class MyNotificationsController < ApplicationController

  extend Calcentral::Cacheable

  def self.translators
    @translators ||= {}
  end

  def get_feed
    render :json => get_feed_internal.to_json
  end

  def get_feed_internal
    self.class.fetch_from_cache session[:user_id] do
      result = {'notifications' => []}
      if session[:user_id]
        Notification.where(:uid => session[:user_id]).each do |notification|
          translator = (MyNotificationsController.translators[notification.translator] ||= notification.translator.constantize.new)
          result['notifications'].push translator.translate notification
        end
      end
      result
    end
  end
end
