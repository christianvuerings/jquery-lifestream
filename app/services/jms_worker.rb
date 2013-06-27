class JmsWorker

  JMS_RECORDING = "#{Rails.root}/fixtures/jms_recordings/ist_jms.txt"

  def initialize
    @jms = nil
    @handler = JmsMessageHandler.new
    @stopped = false
    Rails.cache.write(self.class.cache_key, {
      :last_message_received_at => ''
    })
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
      Rails.cache.write(self.class.cache_key, {
        :last_message_received_at => Time.zone.now
      })
      yield(msg)
    end
  end

  def read_fake
    File.open(JMS_RECORDING, 'r').each("\n\n") do |msg_yaml|
      msg = YAML::load(msg_yaml)
      Rails.cache.write(self.class.cache_key, {
        :last_message_received_at => Time.zone.now
      })
      yield(msg)
    end
  end

  def self.cache_key
    'JmsWorker/Stats'
  end

  def self.ping
    stats = Rails.cache.read(self.cache_key)
    if stats
      if @jms
        "#{self.name} #{@jms.count} received messages; last message received at #{stats[:last_message_received_at].to_s}"
      else
        "#{self.name} JMS connection is not initialized (fake = #{Settings.ist_jms.fake}); last message received at #{stats[:last_message_received_at].to_s}"
      end
    else
      "#{self.name} Stats are not available"
    end
  end

  # Debugging helper.
  def jms
    @jms
  end

end