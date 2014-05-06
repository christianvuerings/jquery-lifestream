module Cache
  module LiveUpdatesEnabled

    def self.included(klass)
      @classes ||= []
      @classes << klass
      klass.extend(ClassMethods)
      # if klass.respond_to?(:get_feed) && klass.respond_to?(:get_feed_as_json) && klass.respond_to?(:get_last_modified)
      #   @classes << klass
      # else
      #   raise ArgumentError.new("Class must have get_last_modified, get_feed, and get_feed_as_json methods to be LiveUpdates eligible")
      # end
    end

    def self.classes
      @classes
    end

  end
end
