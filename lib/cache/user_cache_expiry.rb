module Cache
  module UserCacheExpiry

    def self.notify(uid)
      (Cache::UserCacheExpiry.classes + Cache::LiveUpdatesEnabled.classes).each do |klass|
        klass.expire uid
      end
    end

    def self.included(klass)
      unless klass.respond_to?(:expire)
        raise ArgumentError.new "Class #{klass.name} must implement expire to be expirable"
      end
      @classes ||= []
      @classes << klass
    end

    def self.classes
      unless @classes
        # in TorqueBox messaging context, we have to eager_load! for ourselves,
        # otherwise the @classes array will remain nil forever.
        Rails.application.eager_load!
      end
      @classes
    end

  end
end
