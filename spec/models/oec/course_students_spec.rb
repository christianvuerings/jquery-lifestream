describe Oec::CourseStudents do

  let!(:random_time) { Time.now.to_f.to_s.gsub('.', '') }

  context 'the exported file in the tmp directory' do
    let!(:spec_file) { CSV.read('fixtures/oec/course_students.csv') }
    let!(:ccns) { [12345, 67890] }
    before(:each) {
      all_course_students_query = []
      spec_file.each_with_index do |row, index|
        if index > 0
          all_course_students_query << {
            'COURSE_ID' => row[0],
            'LDAP_UID' => row[1]
          }
        end
      end
      Oec::Queries.stub(:get_all_course_students).with(ccns).and_return(all_course_students_query)
    }

    let!(:export) { Oec::CourseStudents.new(ccns, []).export(random_time) }

    subject { CSV.read(export[:filename]) }
    it {
      should_not be_nil
      should eq(spec_file)
    }
  end
end
