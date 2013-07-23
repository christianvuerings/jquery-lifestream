# Decorate log messages with the current class's name.
# A more flexible but more complex and disruptive approach would be to create a new logger for
# every class, inheriting from the default Rails logger.
module ClassLogger
  class LogWrapper
    def self.decorate_outputters
      [:debug, :info, :warn, :error, :fatal].each do |method_name|
        define_method method_name do |msg|
          Rails.logger.send(method_name, decorate_message(msg))
        end
      end
    end
    decorate_outputters

    def initialize(class_name)
      @class_name = class_name
    end

    def decorate_message(msg)
      "[#{@class_name}] #{msg}"
    end
  end

  module ClassMethods
    def logger
      @class_logger ||= LogWrapper.new(self.name)
    end
  end

  def self.included(klass)
    klass.extend ClassMethods
  end

  def logger
    self.class.logger
  end
end
