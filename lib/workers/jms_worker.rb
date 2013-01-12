class JmsWorker

  def initialize
    @jms = JmsConnection.new
    @handler = JmsMessageHandler.new
  end

  def terminate
    Rails.logger.info "#{Thread.current} is closing"
    @jms.close
    Rails.logger.info "JmsWorker got #{@jms.count} messages"
    @handler.terminate
  end

  def run
    @jms.handle_texts() do |msg|
      @handler.handle(msg)
    end
  end

  def ping
    "#{Thread.list.size} threads; #{Celluloid::Actor.all.count} actors; #{@jms.count} listened messages"
  end

  # For testing support.
  def load_messages(count)
    (1..count).each {|i| @jms.send_message("msgtext #{i}")}
  end
  def jms
    @jms
  end

end