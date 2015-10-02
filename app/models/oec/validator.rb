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

    def validate_and_add(sheet, row, key_columns, opts={})
      opts[:strict] = true unless opts[:strict].present?
      key = key_columns.map { |col| row[col] }.join('-')
      candidate_row = row.slice(*sheet.headers)
      validate(sheet.export_name, key) do |errors|
        sheet.errors_for_row(candidate_row).each { |error| errors.add error }
        if sheet[key] && (sheet[key] != candidate_row)
          conflicting_keys = candidate_row.keys.select { |k| candidate_row[k] != sheet[key][k] }
          conflicting_keys.each do |conflicting_key|
            errors.add "Conflicting values found under #{conflicting_key}: '#{sheet[key][conflicting_key]}', '#{candidate_row[conflicting_key]}'"
          end
          if opts[:strict] == false
            key_for_conflicting_row = "#{key}_001"
            key_for_conflicting_row = key_for_conflicting_row.next until !sheet[key_for_conflicting_row]
            sheet[key_for_conflicting_row] = candidate_row
          end
        else
          sheet[key] ||= candidate_row
        end
      end
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
      log :error, "\n#{message}\n" unless message.blank?
    end

  end
end
