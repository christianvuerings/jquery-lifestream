module Oec
  class Worksheet
    include Enumerable

    def self.base_filename
      "#{self.name.demodulize.underscore}.csv"
    end

    def self.capitalize_keys(row)
      row.inject({}) do |caps_hash, (key, value)|
        caps_hash[key.upcase] = value
        caps_hash
      end
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

    def each
      @rows.each { |key, row| yield row }
    end

    def base_filename
      @opts[:filename] || self.class.base_filename
    end

    def output_filename
      @export_directory.join base_filename
    end

    def headers
      # subclasses override
    end

    def write_csv
      if @rows.any?
        output = CSV.open(output_filename, 'wb', headers: headers, write_headers: true)
        @rows.values.each { |row| output << row }
      else
        output = CSV.open(output_filename, 'wb')
        output << headers
      end
      output.close
    end
  end
end
