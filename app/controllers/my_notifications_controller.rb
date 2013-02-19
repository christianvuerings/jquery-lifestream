class MyNotificationsController < ApplicationController

 def self.translators
    @translators ||= {}
  end

  def get_feed
    result = {'notifications' => []}

    if session[:user_id]
      Notification.where(:uid => session[:user_id]).each do |notification|
        translator = (MyNotificationsController.translators[notification.translator] ||= notification.translator.constantize.new)
        result['notifications'].push translator.translate notification
      end
    end

    render :json => result.to_json
  end
end
