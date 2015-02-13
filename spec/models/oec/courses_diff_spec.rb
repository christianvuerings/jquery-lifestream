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
        Rails.logger.info "Evaluating diff where dept_name = #{dept_name}"
        dept_name_path = dept_name.gsub(/\s/, '_')
        data_from_dept = []
        CSV.read("#{src_dir}/#{dept_name_path}_courses_confirmed.csv").each_with_index do |row, index|
          data_from_dept << Oec::RowConverter.new(row).hashed_row if index > 0 && row.length > 0
        end
        diff = Oec::CoursesDiff.new(dept_name, campus_data_per_dept[dept_name], data_from_dept, 'tmp/oec')
        expect(diff.base_file_name).to include dept_name_path
        # IO.read("#{src_dir}/expected_diff_#{dept_name_path}_courses.csv").should eq IO.read(diff.export[:filename])
        actual_diff = CSV.read diff.export[:filename]
        expected_diff = CSV.read "#{src_dir}/expected_diff_#{dept_name_path}_courses.csv"
        expect(expected_diff.length).to eq actual_diff.length
        expect(expected_diff.length > 0).to eq diff.was_difference_found
      end
    }
  end

end
