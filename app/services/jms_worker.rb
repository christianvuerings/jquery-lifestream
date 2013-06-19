class JmsWorker

  JMS_RECORDING = "#{Rails.root}/fixtures/jms_recordings/ist_jms.txt"

  def initialize
    @jms = nil
    @handler = JmsMessageHandler.new
    @stopped = false
  end

  def start
    if Settings.ist_jms.enabled
      Thread.new { run }
    else
      Rails.logger.info "#{self.class.name} is disabled, not starting thread"
    end
  end

  def stop
    @stopped = true
    Rails.logger.info "#{self.class.name} #{Thread.current} is closing"
    if (@jms)
      @jms.close
      Rails.logger.info "#{self.class.name} got #{@jms.count} messages"
    end
    @handler.terminate
  end

  def run
    if Settings.ist_jms.fake
      read_fake {|msg| @handler.handle(msg)}
    else
      read_jms {|msg| @handler.handle(msg)}
    end
  end

  def read_jms
    until @jms do
      begin
        @jms ||= JmsConnection.new
      rescue => e
        Rails.logger.warn "#{self.class.name} Unable to start JMS listener: #{e.class} #{e.message}"
        sleep(30.minutes)
      end
    end
    @jms.start_listening_with() do |msg|
      if Settings.ist_jms.freshen_recording
        File.open(JMS_RECORDING, 'a') do |f|
          # Use double newline as a serialized object separator.
          # Hat tip to: http://www.skorks.com/2010/04/serializing-and-deserializing-objects-with-ruby/
          f.puts(YAML.dump(msg))
          f.puts('')
        end
      end
      yield(msg)
    end
  end

  def read_fake
    File.open(JMS_RECORDING, 'r').each("\n\n") do |msg_yaml|
      msg = YAML::load(msg_yaml)
      yield(msg)
    end
  end

  def ping
    msg = "#{self.class.name} #{Thread.list.size} threads; #{Celluloid::Actor.all.count} actors"
    msg << "; #{@jms.count} listened messages" if @jms
    msg
  end

  # Debugging helper.
  def jms
    @jms
  end

end