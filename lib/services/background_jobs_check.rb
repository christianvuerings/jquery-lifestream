class BackgroundJobsCheck < TorqueBox::Messaging::MessageProcessor
  extend Cache::Cacheable
  include ClassLogger

  def initialize(opts = {})
    @stopped = false
    # This logic assumes that app server "hostname -s" values exactly match the list of memcached hosts.
    # If the two diverge, we will need a new approach to background check IDs.
    @cluster_nodes = Settings.cache.servers
    @time_between_pings = Settings.background_jobs_check.time_between_pings
  end

  def on_message(body)
    check_in(body)
  end

  def on_error(exception)
    logger.error "Got an exception handling a message: #{exception.inspect}"
    raise exception
  end

  def run
    until @stopped
      # Pause at the top of the loop so as to give the cluster more startup time.
      sleep(@time_between_pings)
      request_ping
    end
  end

  def start
    logger.warn "Starting"
    @stopped = false
    Thread.new do
      run
    end
  end

  def stop
    logger.warn "Stopping"
    @stopped = true
  end

  def check_in(new_timestamp)
    if (id = current_node_id)
      self.class.write_cache(new_timestamp, id)
    end
  end

  def get_feed
    feed = {}
    last_ping = Rails.cache.read(self.class.cache_key 'cluster')
    if last_ping
      non_fatal_skip = -2 * @time_between_pings
      within_normal_lag = (last_ping >= DateTime.now.advance(minutes: -2))
      if last_ping > DateTime.now.advance(seconds: non_fatal_skip)
        @cluster_nodes.each do |node_id|
          node_check_in = Rails.cache.read(self.class.cache_key node_id)
          if node_check_in.blank?
            logger.error("Node #{node_id} has not checked in")
            node_state = 'MISSING'
          elsif node_check_in == last_ping
            node_state = 'OK'
          elsif node_check_in > last_ping.advance(seconds: non_fatal_skip)
            if within_normal_lag
              logger.info("Node #{node_id} logged its last checkin at #{node_check_in}")
              node_state = 'OK'
            else
              logger.warn("Node #{node_id} logged its last checkin at #{node_check_in}")
              node_state = 'LATE'
            end
          else
            logger.error("Node #{node_id} logged its last checkin at #{node_check_in}")
            node_state = 'NOT RUNNING'
          end
          feed[node_id] = node_state
        end
        node_states = feed.values.uniq
        if node_states == ['OK']
          status = 'OK'
        elsif node_states.include? 'OK'
          status = 'PARTIAL'
        else
          status = 'NOT RUNNING'
        end
      else
        status = 'NOT RUNNING'
      end
    else
      status = 'MISSING'
    end
    feed.merge(
      'status' => status,
      'last_ping' => last_ping
    )
  end

  def current_node_id
    # For easier testing on non-clustered developer systems, always identify a single-node
    # server as "localhost" (or whatever the default cache server host is).
    if @cluster_nodes.size > 1
      node_id = ServerRuntime.get_settings['hostname']
      if @cluster_nodes.include?(node_id)
        node_id
      else
        logger.fatal "Message processor is running on host #{node_id}, which is not in the cache.servers configuration!"
        nil
      end
    else
      @cluster_nodes[0]
    end
  end

  def request_ping
    new_timestamp = DateTime.now
    self.class.write_cache(new_timestamp, 'cluster')
    topic = TorqueBox.fetch('/topics/background_jobs_check')
    topic.publish(new_timestamp)
  end

end
