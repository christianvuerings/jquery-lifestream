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
    @jms.start_listening_with() do |msg|
      if Settings.ist_jms.freshen_recording
        File.open("#{Rails.root}/fixtures/jms_recordings/ist_jms.txt", 'a') do |f|
          # Use double newline as a serialized object separator.
          f.puts(YAML.dump(msg))
          f.puts('')
        end
      end
      @handler.handle(msg)
    end
  end

  def ping
    "#{Thread.list.size} threads; #{Celluloid::Actor.all.count} actors; #{@jms.count} listened messages"
  end

  # Helper for testing against a local ActiveMQ server.
  def load_messages(count)
    (1..count).each {|i| @jms.send_message("msgtext #{i}")}
  end
  def jms
    @jms
  end

end