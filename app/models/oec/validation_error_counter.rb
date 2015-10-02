module Oec
  class ValidationErrorCounter

    def initialize(validator, keys)
      @validator = validator
      @keys = keys
    end

    def add(error)
      @error_counter ||= error_counter_for_keys
      @error_counter[error] ||= 0
      @error_counter[error] += 1
    end

    def error_counter_for_keys
      @keys.inject(@validator.errors) do |hash, key|
        hash[key] ||= {}
      end
    end

  end
end
