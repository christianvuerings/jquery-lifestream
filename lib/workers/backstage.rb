ENV["APP_NAME"] = "backstage"
require File.expand_path("../../../config/environment", __FILE__)

class Backstage

  def self.start
    instance = nil
    trap('TERM') do
      Rails.logger.info "Signaled with TERM - shutting down"
      instance.stop
      Thread.main.raise Interrupt
    end
    trap('USR1') do
      Rails.logger.info "Signaled with USR1 - logging stats"
      Rails.logger.info instance.stats
    end
    instance = self.new()
    instance.run
  end

  def initialize
    Celluloid.logger = Rails.logger
    @jms_worker = JmsWorker.new
    @hot_plate_worker = HotPlate.new
  end

  def run
    @jms_worker.run!
    @hot_plate_worker.run!
    until !!@stop
      sleep(30)
    end
  rescue Interrupt
    exit(0)
  ensure
    Rails.logger.info "Stopping all"
    stop
  end

  def stats
    stats = []
    stats << @jms_worker.ping
    stats << @hot_plate_worker.ping
    stats
  end

  def stop
    unless !!@stop
      @stop = true
      @jms_worker.terminate
      @hot_plate_worker.terminate
    end
  end

end