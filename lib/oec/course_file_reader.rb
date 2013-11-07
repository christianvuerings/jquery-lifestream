class CourseFileReader

  attr_reader :ccns, :gsi_ccns

  def initialize(input_filename)
    @ccns = []
    @gsi_ccns = []
    CSV.foreach(input_filename) do |row|
      if row[0]
        val = row[0].split('-')
        if val.length == 3
          split_ccn = val[2].split('_')
          if split_ccn.length == 2
            @gsi_ccns << split_ccn[0].to_i
          else
            @ccns << val[2].to_i
          end
        end
      end
    end
  end

end
