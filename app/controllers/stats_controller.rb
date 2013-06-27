class StatsController < ApplicationController

  def get_stats
    render :json => {
      :threads => Thread.list.size,
      :hot_plate => HotPlate.ping,
      :jms_worker => JmsWorker.ping
    }
  end

end
