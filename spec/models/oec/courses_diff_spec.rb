describe Oec::CoursesDiff do

  let!(:dept_names) { %w{STAT BIOLOGY} }
  let!(:src_dir) { 'fixtures/oec' }

  context 'comparing diff to expected CSV file' do

    before do
      dept_names.each do |dept_name|
        mock_data = "#{src_dir}/db_#{dept_name}_courses.csv"
        courses_query = []
        CSV.read(mock_data).each_with_index do |row, index|
          if row.length > 0
            courses_query << Oec::RowConverter.new(row).hashed_row if index > 0
          end
        end
        expect(Oec::Queries).to receive(:get_courses).with(nil, dept_name).exactly(1).times.and_return courses_query
      end
      expect(Oec::Queries).to receive(:get_courses).at_least(1).times.with(anything).and_return []
    end

    it {
      dept_names.each do |dept_name|
        Rails.logger.info "Evaluating diff where dept_name = #{dept_name}"
        oec_courses_diff = Oec::CoursesDiff.new(dept_name, src_dir, 'tmp/oec')
        actual_diff = CSV.read oec_courses_diff.export[:filename]
        expected_diff = CSV.read "#{src_dir}/expected_diff_#{dept_name}_courses.csv"
        expect(actual_diff.length).to eq expected_diff.length
      end
    }
  end

end
