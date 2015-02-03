describe Oec::CoursesDiff do

  let!(:dept_names) { %w{STAT BIOLOGY} }
  let!(:src_dir) { 'fixtures/oec' }

  context 'comparing diff to expected CSV file' do

    before do
      dept_names.each do |dept_name|
        mock_data = "#{src_dir}/db_#{dept_name}_courses.csv"
        courses_query = []
        CSV.read(mock_data).each_with_index do |row, index|
          if index > 0 && row.length > 0
            hashed_row = Oec::RowConverter.new(row).hashed_row
            # Arbitrary, non-zero enrollment
            hashed_row['enrollment_count'] = 50
            courses_query << hashed_row
          end
        end
        expect(Oec::Queries).to receive(:get_courses).with(nil, dept_name).exactly(1).times.and_return courses_query
      end
      expect(Oec::Queries).to receive(:get_courses).at_least(1).times.with(anything).and_return []
    end

    it {
      dept_names.each do |dept_name|
        Rails.logger.info "Evaluating diff where dept_name = #{dept_name}"
        diff = Oec::CoursesDiff.new(dept_name, src_dir, 'tmp/oec')
        expect(diff.base_file_name).to start_with dept_name
        actual_diff = CSV.read diff.export[:filename]
        expected_diff = CSV.read "#{src_dir}/expected_diff_#{dept_name}_courses.csv"
        expect(actual_diff.length).to eq expected_diff.length
      end
    }
  end

end
