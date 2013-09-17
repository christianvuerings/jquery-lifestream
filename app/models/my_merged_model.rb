class MyMergedModel
  include ActiveAttr::Model
  extend Calcentral::Cacheable

  def initialize(uid, options={})
    @uid = uid
    @options = options
    if options
      @original_uid = options[:original_user_id]
    end
  end

  def init
    # override to do any initialization that requires database access or other expensive computation.
    # If you do expensive work from initialize, it will happen even when this object is cached -- not desirable!
  end

  def get_feed(*opts)
    uid = @uid
    uid = Calcentral::PSEUDO_USER_PREFIX + @uid if is_acting_as_nonfake_user?

    last_modified = get_last_modified uid
    old_hash = last_modified[:hash]
    Rails.logger.info "Last_modified = #{last_modified.inspect}"

    self.class.fetch_from_cache uid do
      init
      feed = get_feed_internal(*opts)
      Rails.logger.info "Feed = #{feed.to_json.to_s}"
      last_modified[:timestamp] = Time.now.to_i
      last_modified[:hash] = Digest::SHA1.hexdigest(feed.to_json)
      Rails.logger.info "Last_modified key = #{self.class.last_modified_cache_key(uid)} just before writing: #{last_modified.inspect}"
      if old_hash != last_modified[:hash]
        Rails.logger.info "Last_modified hash has changed, sending feed changed message"
        self.class.queue.publish({:feed => self.class.name, :uid => uid})
      end

      Rails.cache.write(self.class.last_modified_cache_key(uid), last_modified, :expires_in => 28.days)
      feed
    end
  end

  def get_last_modified(uid)
    Rails.cache.fetch(self.class.last_modified_cache_key(uid), :expires_in => 28.days) do
      {
        :hash => '',
        :timestamp => 0
      }
    end
  end

  def self.last_modified_cache_key(uid)
    "user/#{uid}/#{self.name}/LastModified"
  end

  def expire_cache
    self.class.expire(@uid)
  end

  def is_acting_as_nonfake_user?
    @original_uid && @uid != @original_uid && !UserAuth.is_test_user?(@uid)
  end

  def self.queue
    @queue ||= TorqueBox::Messaging::Queue.new('/queues/feed_changed')
  end

end
