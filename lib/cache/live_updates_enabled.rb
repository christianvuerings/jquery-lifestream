module Cache
  module LiveUpdatesEnabled

    def self.included(klass)
      unless klass.method_defined?(:get_feed) && klass.method_defined?(:get_feed_as_json)
        raise ArgumentError.new "Class #{klass.name} must implement get_feed and get_feed_as_json to LiveUpdates eligible"
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
