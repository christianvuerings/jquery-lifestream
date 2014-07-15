module Cache
  module LiveUpdatesEnabled

    def self.included(klass)
      unless klass.respond_to?(:get_last_modified) && klass.method_defined?(:warm_cache)
        raise ArgumentError.new "Class #{klass.name} must implement get_last_modified and warm_cache to be LiveUpdates eligible"
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
