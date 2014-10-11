describe Oec::Courses do

  let!(:random_time) { Time.now.to_f.to_s.gsub('.', '') }

  context 'exported file in tmp directory' do
    let!(:spec_file) { CSV.read('fixtures/oec/courses.csv') }

    before(:each) {
      all_courses_query = []
      spec_file.each_with_index do |row, index|
        if index > 0
          course_id = row[0]
          split_course_id = course_id.split('-')
          cross_listings = row[3]
          all_courses_query << {
            'term_yr' => split_course_id[0],
            'term_cd' => split_course_id[1],
            'course_cntl_num' => split_course_id[2].split('_')[0],
            'course_id' => course_id,
            'course_name' => row[1],
            'cross_listed_flag' => row[2],
            'cross_listed_name' => cross_listings.present? ? cross_listings[/\((.*)\)/,1] : nil,
            'course_title_short' => cross_listings.present? ? cross_listings[/(.*?)\s\(/,1] : nil,
            'dept_name' => row[4],
            'catalog_id' => row[5],
            'instruction_format' => row[6],
            'section_num' => row[7],
            'primary_secondary_cd' => row[8],
            'ldap_uid' => row[9],
            'first_name' => row[10],
            'last_name' => row[11],
            'full_name' => row[12],
            'email_address' => row[13],
            'instructor_func' => row[14],
            'blue_role' => row[15],
            'evaluate' => row[16],
            'evaluation_type' => row[17],
            'modular_course' => row[18],
            'start_date' => row[19],
            'end_date' => row[20]
          }
        end
      end
      expect(Oec::Queries).to receive(:get_all_courses).with('54432, 87672').exactly(2).times.and_return([all_courses_query[8], all_courses_query[9]])
      expect(Oec::Queries).to receive(:get_all_courses).with('54441, 87675').exactly(2).times.and_return([all_courses_query[10], all_courses_query[11]])
      expect(Oec::Queries).to receive(:get_all_courses).with('72198, 87690').exactly(2).times.and_return([all_courses_query[12], all_courses_query[13]])
      expect(Oec::Queries).to receive(:get_all_courses).and_return(all_courses_query)
    }

    let!(:export) { Oec::Courses.new.export(random_time) }

    subject { CSV.read(export[:filename]) }
    it {
      should_not be_nil
      should have_exactly(9).items
      expected_course_ids = ['COURSE_ID', '2013-D-87672', '2013-D-54432', '2013-D-87675', '2013-D-54441', '2013-D-87690', '2013-D-72198', '2013-D-87693', '2013-D-02567']
      subject.each do |entry|
        expected_course_ids.count(entry[0]).should eql(1)
        expected_course_ids.delete(entry[0])
      end
      expected_course_ids.count.should eql(0)
    }
  end

end
