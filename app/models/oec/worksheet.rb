module Oec
  class Worksheet
    include Enumerable

    def self.capitalize_keys(row)
      row.inject({}) do |caps_hash, (key, value)|
        caps_hash[key.upcase] = value
        caps_hash
      end
    end

    def self.export_name
      self.name.demodulize.underscore
    end

    def initialize(export_directory, opts={})
      FileUtils.mkdir_p export_directory unless File.exists? export_directory
      @export_directory = export_directory
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
