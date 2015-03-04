describe Oec::CoursesDiff do

  let!(:dept_names) { %w{STAT BIOLOGY POL\ SCI} }
  let!(:data_corrected_by_dept) { {} }
  let!(:campus_data_per_dept) { {} }
  let!(:src_dir) { 'fixtures/oec' }

  context 'comparing diff to expected CSV file' do

    before do
      dept_names.each do |dept_name|
        campus_data_per_dept[dept_name] = []
        mock_data = "#{src_dir}/db_#{dept_name.gsub(/\s/, '_')}_courses.csv"
        CSV.read(mock_data).each_with_index do |row, index|
          if index > 0 && row.length > 0
            hashed_row = Oec::RowConverter.new(row).hashed_row
            # Arbitrary, non-zero enrollment
            hashed_row['enrollment_count'] = 50
            campus_data_per_dept[dept_name] << hashed_row
          end
        end
      end
    end

    it {
      dept_names.each do |dept_name|
        dept_name_path = dept_name.gsub(/\s/, '_')
        data_from_dept = []
        CSV.read("#{src_dir}/#{dept_name_path}_courses_confirmed.csv").each_with_index do |row, index|
          row_with_deliberate_errors = row.length == 0 || row[0].blank?
          data_from_dept << Oec::RowConverter.new(row).hashed_row if index > 0 && !row_with_deliberate_errors
        end
        diff = Oec::CoursesDiff.new(dept_name, campus_data_per_dept[dept_name], data_from_dept, 'tmp/oec')
        expect(diff.base_file_name).to include dept_name_path
        actual_diff = CSV.read diff.export[:filename]
        expected_diff = CSV.read "#{src_dir}/expected_diff_#{dept_name_path}_courses.csv"
        expect(expected_diff.length).to eq actual_diff.length
        expect(expected_diff.length > 0).to eq diff.was_difference_found
        if dept_name == 'STAT'
          # Bogus ids in STAT_courses_confirmed.csv
          expected_error_counts = { '2015-B-666' => 1, '2015-B-55555' => 1, '1999-E-BAD/CCN_X' => 6, '2015-B-111' => 1, '2015-B-33333' => 1 }
          expected_error_counts.each do |course_id, error_count|
            expect(diff.errors_per_course_id[course_id].length).to eq error_count
          end
        end
      end
    }
  end

end
