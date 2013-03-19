module ActiveRecordHelper
  def log_access
    # Most of this logging introspection will add a lot of noise as well have some kind of performance hit. Would be good to keep
    # this hidden away under DEBUG mode. Otherwise, this method call is a noop.
    if Rails.logger.debug?
      connection_id = self.connection.object_id
      Rails.logger.debug "#{self.class.name} using connection_id: #{connection_id}, connnected = #{self.connection.pool.active_connection?}"
      self.connection_handler.connection_pools.each do |conn_pool_hash, conn_pool|
        live_connections = conn_pool.connections
        Rails.logger.debug "#{self.class.name} current connection pool (#{conn_pool_hash}-#{conn_pool_hash.adapter_method}) count: #{live_connections.size}, current connection pool: #{live_connections.map{|conn| conn.object_id}}"
      end

      actors = Celluloid::Actor.all
      actor_class_names = actors.map { |actor|
        begin
          actor.class.name
        rescue Celluloid::DeadActorError
          "DeadActor"
        end
      }
      Rails.logger.debug "Live Actors in system #{actors.size}: #{actor_class_names}"
    end
  end
end