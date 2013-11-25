class StatsController < ApplicationController

  def get_stats
    render :json => {
      :threads => Thread.list.size,
      :hot_plate => HotPlate.ping,
      :live_updates_warmer => LiveUpdatesWarmer.ping,
      :jms_worker => JmsWorker.ping
    }
  end

end
