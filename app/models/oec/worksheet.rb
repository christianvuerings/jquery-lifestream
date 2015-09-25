module Oec
  class Worksheet
    include Enumerable

    DEFAULT_EXPORT_PATH = Rails.root.join('tmp', 'oec')

    class << self
      attr_accessor :row_validations

      def init_validations
        self.row_validations ||= []
      end

      def inherited(subclass)
        subclass.init_validations
      end
    end

    def self.validate(key, &blk)
      self.row_validations << {key: key, blk: blk}
    end

    def self.capitalize_keys(row)
      row.inject({}) do |caps_hash, (key, value)|
        caps_hash[key.upcase] = value
        caps_hash
      end
    end

    def self.export_name
      self.name.demodulize.underscore
    end

    def self.from_csv(csv, opts={})
      return unless csv && (parsed_csv = CSV.parse csv)
      instance = self.new opts
      (header_row = parsed_csv.shift) until (header_row == instance.headers || parsed_csv.empty?)
      raise ArgumentError, "Header mismatch: cannot create instance of #{self.name} from CSV" unless header_row
      parsed_csv.each_with_index { |row, index| instance[index] = Hash[instance.headers.zip row] }
      instance
    end

    def errors_for_row(row)
      errors = self.class.row_validations.map do |validation|
        if row[validation[:key]].blank?
          "Blank #{validation[:key]}"
        elsif (message = validation[:blk].call row)
          "#{message} #{validation[:key]} #{row[validation[:key]]}"
        end
      end
      errors.compact
    end

    def initialize(opts={})
      @export_directory = opts[:export_path] || DEFAULT_EXPORT_PATH
      FileUtils.mkdir_p @export_directory unless File.exists? @export_directory
      @opts = opts
      @rows = {}
    end

    def [](key)
      @rows[key]
    end

    def []=(key, value)
      @rows[key] = value
    end

    def csv_export_path
      @export_directory.join "#{export_name}.csv"
    end

    def each
      @rows.each { |key, row| yield row }
    end

    def export_name
      @opts[:export_name] || self.class.export_name
    end

    def headers
      # subclasses override
    end

    def write_csv
      if @rows.any?
        output = CSV.open(csv_export_path, 'wb', headers: headers, write_headers: true)
        @rows.values.each { |row| output << row }
      else
        output = CSV.open(csv_export_path, 'wb')
        output << headers
      end
      output.close
    end
  end
end
