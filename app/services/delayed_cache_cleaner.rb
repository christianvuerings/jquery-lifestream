class DelayedCacheCleaner

  include ClassLogger

  def initialize(options = {})
    @key = options["key"]
  end

  def run
    logger.warn "Handling cache deletion for key: #{@key}"
    Rails.cache.delete(@key, :force => true) if @key.present?
    nil
  end

  def self.queue(cache_key, delay_ms = 5000)
    if ENV['IS_TORQUEBOX']
      logger.warn "Queueing up cache deletion for key #{cache_key}"
      TorqueBox::ScheduledJob.at('DelayedCacheCleaner', :in => delay_ms, :config => {"key" => cache_key})
    else
      logger.warn "TorqueBox not running; delayed cache deletion is disabled. key: #{cache_key}"
    end
    nil
  end

end
