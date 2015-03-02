describe Oec::CourseStudents do

  context 'the exported file in the tmp directory' do
    let!(:spec_file) { CSV.read 'fixtures/oec/course_students.csv' }
    let!(:ccn_set) { Set.new }
    let!(:annotated_ccn_hash) { { } }

    before(:each) {
      ccn_set_results = []
      annotated_ccn_results = []
      unique_annotated_rows = []
      spec_file.each_with_index do |row, index|
        if index > 0
          course_id = row[0]
          annotated_cnn = course_id.split('-')[2].split('_')
          ccn = annotated_cnn[0].to_i
          if annotated_cnn.length == 2
            annotated_ccn_hash[ccn] ||= Set.new
            annotated_ccn_hash[ccn] << annotated_cnn[1]
            # Query results will not have annotation in course_id so we strip.
            row = {'COURSE_ID' => course_id.split('_')[0], 'LDAP_UID' => row[1]}
            row_as_string = row.to_s
            unless unique_annotated_rows.include? row_as_string
              annotated_ccn_results << row unless annotated_ccn_results.include? annotated_ccn_results
              unique_annotated_rows << row_as_string
            end
          else
            ccn_set << ccn
            ccn_set_results << { 'COURSE_ID' => course_id, 'LDAP_UID' => row[1] }
          end
        end
      end
      Oec::Queries.stub(:get_all_course_students).with(ccn_set).and_return ccn_set_results
      Oec::Queries.stub(:get_all_course_students).with(annotated_ccn_hash.keys).and_return annotated_ccn_results
    }

    let!(:export) { Oec::CourseStudents.new(ccn_set, annotated_ccn_hash, 'tmp/oec').export }

    subject { CSV.read export[:filename] }
    it {
      should_not be_nil
      should =~ spec_file
    }
  end

end
