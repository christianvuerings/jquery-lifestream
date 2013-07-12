class JmsWorker

  JMS_RECORDING = "#{Rails.root}/fixtures/jms_recordings/ist_jms.txt"

  def initialize
    @jms = nil
    @handler = JmsMessageHandler.new
    @stopped = false
    @count = 0
  end

  def start
    if Settings.ist_jms.enabled
      Rails.logger.warn "#{self.class.name} Starting up"
      Thread.new { run }
    else
      Rails.logger.warn "#{self.class.name} is disabled, not starting thread"
    end
    Rails.cache.write(self.class.server_cache_key, ServerRuntime.get_settings["hostname"], :expires_in => 0)
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
      write_stats(@jms.count)
      yield(msg)
    end
  end

  def read_fake
    File.open(JMS_RECORDING, 'r').each("\n\n") do |msg_yaml|
      msg = YAML::load(msg_yaml)
      @count += 1
      write_stats(@count)
      yield(msg)
    end
  end

  def write_stats(count)
    Rails.cache.write(self.class.cache_key, {
      :last_message_received_at => Time.zone.now,
      :count => count
    }, :expires_in => 0)
  end

  def self.cache_key
    'JmsWorker/Stats'
  end

  def self.server_cache_key
    'JmsWorker/Server'
  end

  def self.ping
    stats = Rails.cache.read(self.cache_key)
    server = Rails.cache.read(self.server_cache_key)
    if stats
      "#{self.name} Running on #{server}; #{stats[:count]} received messages; last message received at #{stats[:last_message_received_at].to_s}"
    else
      "#{self.name} Running on #{server}; Stats are not available"
    end
  end

  # Debugging helper.
  def jms
    @jms
  end

end