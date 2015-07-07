class PingController < ApplicationController

  def do
    # IST's nagios and our check-alive.sh script use this endpoint to tell whether the server's up.
    # Don't modify its content unless you have general agreement that it's necessary to do so.
    begin
      ping_state = ping
    rescue StandardError => e
      Rails.logger.fatal e
    end
    if ping_state
      feed = {
        server_alive: true
      }
      if Settings.features.background_jobs_check
        feed[:background_jobs_check] = background_jobs_check
      end
      render json: feed.to_json
    else
      render :nothing => true, :status => 503
    end
  end

  private

  def ping
    # rate limit so we don't check server status excessively often
    Rails.cache.fetch(
      "server_ping_#{ServerRuntime.get_settings["hostname"]}",
      :expires_in => 30.seconds) {
      if !User::Data.database_alive?
        raise "CalCentral database is currently unavailable"
      end
      if !CampusOracle::Queries.database_alive?
        raise "Campus database is currently unavailable"
      end
      true
    }
  end

  def background_jobs_check
    Rails.cache.fetch(
      "server_background_jobs_check",
      :expires_in => Settings.background_jobs_check.time_between_pings) {
      BackgroundJobsCheck.new.get_feed
    }
  end

end
