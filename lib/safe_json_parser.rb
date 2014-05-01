module SafeJsonParser

  module ClassMethods
    def safe_json(str)
      begin
        return JSON.parse str
      rescue JSON::ParserError => e
        Rails.logger.error "[#{self.name}] Encountered invalid JSON string: #{e.inspect}"
        return nil
      end
    end
  end

  def self.included(klass)
    klass.extend ClassMethods
  end

  # convert a String into JSON, returning nil if there's a parse error
  def safe_json(str)
    self.class.safe_json(str)
  end

end
