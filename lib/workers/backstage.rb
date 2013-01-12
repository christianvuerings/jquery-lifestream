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
    # Once we have more workers, we'll probably use something like a supervision group to manage them
    # in a consistent fashion. With only one worker, there's not enough to generalize from.
    @worker = JmsWorker.new
  end

  def run
    @worker.run
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
    @worker.ping
  end

  def stop
    unless !!@stop
      @stop = true
      @worker.terminate
    end
  end

end