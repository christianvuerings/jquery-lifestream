module Oec
  class FileReader

    attr_reader :ccn_set, :annotated_ccn_hash

    def initialize(input_filename)
      @ccn_set = Set.new
      @annotated_ccn_hash = {}
      CSV.foreach(input_filename) do |row|
        if row[0]
          course_id = row[0].split('-')
          if course_id.length == 3
            # Annotation is text after underscore.
            ccn_with_annotation = course_id[2].split('_')
            if ccn_with_annotation.length == 2
              ccn = ccn_with_annotation[0].to_i
              @annotated_ccn_hash[ccn] ||= Set.new
              @annotated_ccn_hash[ccn] << ccn_with_annotation[1]
            else
              @ccn_set << course_id[2].to_i
            end
          end
        end
      end
    end

  end
end
