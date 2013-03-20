module ActiveRecordHelper
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

  module ClassMethods
    # No clue where this class method could be called from, so making the params more explicit.
    def log_access(conn, conn_handler, name)
      ActiveRecordHelper.shared_log_access(conn, conn_handler, name)
    end

    def log_threads
      ActiveRecordHelper.shared_log_threads
    end
  end

  protected

  def self.shared_log_access(conn, conn_handler, name)
    # Most of this logging introspection will add a lot of noise as well have some kind of performance hit. Would be good to keep
    # this hidden away under DEBUG mode. Otherwise, this method call is a noop.
    if Rails.logger.debug?
      connection_id = conn.object_id
      Rails.logger.debug "#{name} using connection_id: #{connection_id}, connnected = #{conn.pool.active_connection?}"
      conn_handler.connection_pools.each do |conn_pool_hash, conn_pool|
        live_connections = conn_pool.connections
        Rails.logger.debug "#{name} current connection pool (#{conn_pool_hash}-#{conn_pool_hash.adapter_method}) count: #{live_connections.size}, current connection pool: #{live_connections.map{|conn_sub| conn_sub.object_id}}"
      end
    elsif Rails.logger.info?
      Rails.logger.info "#{conn_pool.connections.size} current connections."
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

end