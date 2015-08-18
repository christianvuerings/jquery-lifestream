require 'csv'

module OecLegacy
  module Csv
    extend self

    def read(filename)
      file_contents = File.read filename
      CSV.parse validate_encoding(file_contents, filename)
    end

    def validate_encoding(str, filename)
      ec = Encoding::Converter.new('binary', 'UTF-8')
      ec.convert str
    rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError => e
      if (m = e.message.match /"+\\x([^"]+)"/)
        offending_character = m[1].hex.chr
        message = "Offending character #{offending_character.dump} in #{filename}"
        str.each_line.with_index(1) do |line, line_number|
          line.force_encoding 'binary'
          if (character_index = line.index offending_character)
            message << " at line #{line_number}, character #{character_index}"
            break
          end
        end
      else
        message = "#{e.message} in #{filename}"
      end
      raise e.class, message
    end
  end
end
