module Oec
  class CsvExport < ::CsvExport
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

    def initialize(export_dir, opts={})
      @rows = {}
      @filename = opts[:filename]
      super(export_dir)
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
      @filename || self.class.base_filename
    end

    def export
      if @rows.any?
        output = CSV.open(output_filename, 'wb', headers: headers, write_headers: true)
        @rows.values.each { |row| output << row }
      else
        output = CSV.open(output_filename, 'wb')
        output << headers
      end
      output.close
    end

    def headers
      # subclasses override
    end

    def output_filename
      export_directory.join base_filename
    end

  end
end
