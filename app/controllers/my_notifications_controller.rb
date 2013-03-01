require 'lib/cacheable.rb'

class MyNotificationsController < ApplicationController

  extend Calcentral::Cacheable

  def self.translators
    @translators ||= {}
  end

  def get_feed

    result = {'notifications' => []}

    if session[:user_id]
      self.class.fetch_from_cache session[:user_id] do
        Notification.where(:uid => session[:user_id]).each do |notification|
          translator = (MyNotificationsController.translators[notification.translator] ||= notification.translator.constantize.new)
          result['notifications'].push translator.translate notification
        end
      end
    end

    render :json => result.to_json
  end
end
