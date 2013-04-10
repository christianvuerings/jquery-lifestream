module ActiveRecordHelper

  # The justification for doing atomic wrapping around each database call with use_pooled_connection
  # is due to our preference of holding on to connections for the shortest time possible. Due to the way
  # our app is structured, following the standard rails scheme of wrapping the with_connection at a much higher
  # level would cause certain connections to be held for much longer than we would like (while waiting for proxy
  # call responses, doing transform on data), while having nothing to do with the database. By doing wrapping at
  # a more atomic level, we can help avoid the overconsumption of connections and sitting idle when some other
  # request can't obtain db connections.
  #
  # One idea to pursue is to have a method that helps act as a proxy call to built in ActiveRecord database calls
  # that will automatically wrap it up with the "with_connection" proc. That should help reduce some of the
  # noise floating around in all the different levels of the app with the with_pooled_connection blocks. Another
  # idea is to possibly follow the example of the activerecord-wrap-with-connection gem, and have it "autowrap"
  # at a much higher level.

  def self.included(klass)
    klass.extend ClassMethods
  end

  # Should normally be used when within a subclass instance of ActiveRecord::Base
  def log_access
    ActiveRecordHelper.shared_log_access(self.connection, self.connection_handler, self.class.name)
  end

  def log_threads
    ActiveRecordHelper.shared_log_threads
  end

  def use_pooled_connection(&block)
    ActiveRecordHelper.shared_use_pooled_connection(&block)
  end

  module ClassMethods
    # No clue where this class method could be called from, so making the params more explicit.
    def log_access(conn, conn_handler, name)
      ActiveRecordHelper.shared_log_access(conn, conn_handler, name)
    end

    def log_threads
      ActiveRecordHelper.shared_log_threads
    end

    def use_pooled_connection(&block)
      ActiveRecordHelper.shared_use_pooled_connection(&block)
    end
  end

  protected

  def self.shared_log_access(conn, conn_handler, name)
    # Most of this logging introspection will add a lot of noise as well have some kind of performance hit. Would be good to keep
    # this hidden away under DEBUG mode. Otherwise, this method call is a noop.
    if Rails.logger.debug?
      connection_id = conn.object_id
      Rails.logger.debug "#{name} using connection_id: #{connection_id}, connected = #{conn.pool.active_connection?}"
      conn_handler.connection_pools.each do |conn_pool_hash, conn_pool|
        live_connections = conn_pool.connections
        Rails.logger.debug "#{name} current connection pool (#{conn_pool_hash}-#{conn_pool_hash.adapter_method}) count: #{live_connections.size}, current connection pool: #{live_connections.map{|conn_sub| conn_sub.object_id}}"
      end
    elsif Rails.logger.info?
      conn_handler.connection_pools.each do |conn_pool_hash, conn_pool|
        live_connections = conn_pool.connections
        Rails.logger.info "#{name} current connection pool (#{conn_pool_hash}-#{conn_pool_hash.adapter_method}) count: #{live_connections.size}"
      end
    end
  end

  def self.shared_log_threads
    if Rails.logger.debug?
      actors = Celluloid::Actor.all
      actor_class_names = actors.map { |actor|
        begin
          actor.class.name
        rescue Celluloid::DeadActorError
          "DeadActor"
        end
      }
      Rails.logger.debug "Live Actors in system #{actors.size}: #{actor_class_names}"
    elsif Rails.logger.info?
      Rails.logger.info "#{Celluloid::Actor.all.size} actors in the system."
    end
  end

  def self.shared_use_pooled_connection(&block)
    amended_block = Proc.new {
      if Rails.logger.debug?
          Rails.logger.debug "#{self.name} using connection_pool.with_connection:"
      end
      yield block if block_given?
    }
    ActiveRecord::Base.connection_pool.with_connection(&amended_block)
  end
end
