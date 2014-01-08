class JmsWorker

  extend Calcentral::StatAccumulator

  JMS_RECORDING = "#{Rails.root}/fixtures/jms_recordings/ist_jms.txt"

  RECEIVED_MESSAGES = "Received Messages"
  LAST_MESSAGE_RECEIVED_TIME = "Last Message Received Time"

  def initialize(opts = {})
    @jms = nil
    @handler = JmsMessageHandler.new
    @stopped = false
  end

  def start
    if Settings.ist_jms.enabled
      Rails.logger.warn "#{self.class.name} Starting up"
      Thread.new { run }
    else
      Rails.logger.warn "#{self.class.name} is disabled, not starting thread"
    end
  end

  def stop
    @stopped = true
    Rails.logger.warn "#{self.class.name} #{Thread.current} is stopping"
    Rails.logger.warn "#{JmsWorker.ping}"
  end

  def run
    if Settings.ist_jms.fake
      Rails.logger.warn "#{self.class.name} Reading fake messages"
      read_fake { |msg| @handler.handle(msg) }
    else
      read_jms { |msg| @handler.handle(msg) }
    end
  end

  def read_jms
    until @jms do
      begin
        @jms ||= JmsConnection.new
      rescue => e
        Rails.logger.error "#{self.class.name} Unable to start JMS listener: #{e.class} #{e.message}"
        sleep(30.minutes)
      end
    end
    Rails.logger.warn "#{self.class.name} JMS Connection is initialized"
    @jms.start_listening_with() do |msg|
      if Settings.ist_jms.freshen_recording
        File.open(JMS_RECORDING, 'a') do |f|
          # Use double newline as a serialized object separator.
          # Hat tip to: http://www.skorks.com/2010/04/serializing-and-deserializing-objects-with-ruby/
          f.puts(YAML.dump(msg))
          f.puts('')
        end
      end
      write_stats
      yield(msg)
    end
  end

  def read_fake
    File.open(JMS_RECORDING, 'r').each("\n\n") do |msg_yaml|
      msg = YAML::load(msg_yaml)
      write_stats
      yield(msg)
    end
  end

  def write_stats
    self.class.increment(RECEIVED_MESSAGES, 1)
    self.class.write(LAST_MESSAGE_RECEIVED_TIME, Time.zone.now)
  end

  def self.ping
    received_messages = self.report RECEIVED_MESSAGES
    last_received_message_time = self.report LAST_MESSAGE_RECEIVED_TIME
    server = ServerRuntime.get_settings["hostname"]
    if received_messages
      "#{self.name} Running on #{server}; #{received_messages}; #{last_received_message_time}"
    else
      "#{self.name} Running on #{server}; Stats are not available"
    end
  end

  # Debugging helper.
  def jms
    @jms
  end

end
