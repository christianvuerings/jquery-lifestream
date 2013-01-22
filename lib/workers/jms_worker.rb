class JmsWorker
  include Celluloid

  def initialize
    @jms = nil
    @handler = JmsMessageHandler.new
  end

  def finalize
    Rails.logger.info "#{Thread.current} is closing"
    if (@jms)
      @jms.close
      Rails.logger.info "JmsWorker got #{@jms.count} messages"
    end
    @handler.terminate
  end

  def run
    until @jms do
      begin
        @jms ||= JmsConnection.new
      rescue => e
        Rails.logger.warn "Unable to start JMS listener: #{e}"
        sleep(30.minutes)
      end
    end
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
    msg = "#{Thread.list.size} threads; #{Celluloid::Actor.all.count} actors"
    msg << "; #{@jms.count} listened messages" if @jms
    msg
  end

  # Debugging helper.
  def jms
    @jms
  end

end