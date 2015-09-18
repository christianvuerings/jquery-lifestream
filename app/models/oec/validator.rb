module Oec
  module Validator

    attr_accessor :errors

    def validate(*keys)
      @errors ||= {}
      yield ValidationErrorCounter.new(self, keys)
    end

    def valid?(*keys)
      errors_for_keys = keys.inject(@errors) { |errors, key| errors[key] if errors }
      errors_for_keys.blank?
    end

    def log_validation_errors
      message = ''
      @errors.each do |sheet_name, errors_by_key|
        message.concat <<-summary

#{Berkeley::Departments.get(sheet_name)} errors:
        summary
        errors_by_key.each do |key, errors|
          message << "\n#{key.present? ? key : '[Blank key]'}:"
          errors.each do |error_message, count|
            message << "\n    #{error_message}"
            message << " (#{count} rows)" if count > 1
          end
          message << "\n"
        end
      end
      log :error, message unless message.blank?
    end

  end
end
