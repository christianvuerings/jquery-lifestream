class StatsController < ApplicationController

  include TorqueBox::Injectors

  def get_stats
    hot_plate = fetch('service:HotPlate')
    jms_worker = fetch('service:JmsWorker')

    render :json => {
      :threads => Thread.list.size,
      :hot_plate => hot_plate.ping,
      :jms_worker => jms_worker.ping
    }
  end

end
