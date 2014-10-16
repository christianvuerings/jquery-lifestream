describe Oec::Courses do

  let!(:random_time) { Time.now.to_f.to_s.gsub('.', '') }

  before(:suite) do
    cross_listed_targets = {}
    cross_listed_names = []
    dept_names = ['ANTHRO', 'MATH', 'POL SCI', 'STAT']
    dept_names.each do |dept_name|
      courses_query = []
      CSV.read('fixtures/oec/courses.csv').each_with_index do |row, index|
        if index > 0 && row[4] == dept_name
          course_id = row[0]
          split_course_id = course_id.split('-')
          cross_listings = row[3]
          ccn = split_course_id[2].split('_')[0]
          cross_listed_name = cross_listings.present? ? cross_listings[/\((.*)\)/, 1] : nil
          result_set = {
            'term_yr' => split_course_id[0],
            'term_cd' => split_course_id[1],
            'course_cntl_num' => ccn,
            'course_id' => course_id,
            'course_name' => row[1],
            'cross_listed_flag' => row[2],
            'cross_listed_name' => cross_listed_name,
            'course_title_short' => cross_listings.present? ? cross_listings[/(.*?)\s\(/, 1] : nil,
            'dept_name' => dept_name,
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
          courses_query << result_set
          cross_listed_targets[ccn.to_i] = result_set
          cross_listed_names << cross_listed_name if cross_listed_name.present?
        end
      end
      expect(Oec::Queries).to receive(:get_courses).with(nil, dept_name).exactly(1).times.and_return(courses_query)
      expect(courses_query.length).to eq(1) if dept_name == 'ANTHRO'
      expect(courses_query.length).to eq(2) if dept_name == 'MATH'
      expect(courses_query.length).to eq(2) if dept_name == 'POL SCI'
      expect(courses_query.length).to eq(6) if dept_name == 'STAT'
    end
    cross_listed_names.each do |cross_listed_name|
      result_set = []
      cross_listed_name.split(',').each do |ccn|
        row_by_ccn = cross_listed_targets[ccn.to_i]
        expect(row_by_ccn).to_not be_nil
        result_set << row_by_ccn
      end
      expect(Oec::Queries).to receive(:get_courses).with(cross_listed_name).exactly(1).times.and_return(result_set)
    end
    expect(Oec::Queries).to receive(:get_secondary_cross_listings).with([]).and_return([]);
  end

  context 'reading ANTHRO csv file' do
    subject { get_csv 'ANTHRO' }
    it {
      contain_exactly('COURSE_ID', '2013-D-02567')
    }
  end

  context 'reading MATH csv file' do
    subject { get_csv 'MATH' }
    it {
      contain_exactly('COURSE_ID', '2013-D-87672', '2013-D-54432', '2013-D-87675', '2013-D-54441', '2013-D-87673', '2013-D-87691')
    }
  end

  context 'reading POL SCI csv file' do
    subject { get_csv 'POL SCI' }
    it {
      contain_exactly('COURSE_ID', '2013-D-72198', '2013-D-72198')
    }
  end

  context 'reading STAT csv file' do
    subject { get_csv 'STAT' }
    it {
      contain_exactly('COURSE_ID', '2013-D-87672', '2013-D-54432', '2013-D-54441', '2013-D-72199', '2013-D-87691', '2013-D-87693')
    }
  end

  def get_csv(dept_name)
    export = Oec::Courses.new(dept_name).export(random_time)
    csv_read = CSV.read(export[:filename])
    csv_read
  end

end
