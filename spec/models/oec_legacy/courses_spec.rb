describe OecLegacy::Courses do

  before(:suite) do
    cross_listed_targets = {}
    cross_listed_names = []
    dept_names = %w(ANTHRO MATH 'POL SCI' STAT)
    dept_names.each do |dept_name|
      courses_query = []
      CSV.read('fixtures/oec_legacy/courses.csv').each_with_index do |row, index|
        if index > 0 && row[4] == dept_name
          result_set = OecLegacy::RowConverter.new(row).hashed_row
          courses_query << result_set
          cross_listed_targets[result_set['course_cntl_num'].to_i] = result_set
          cross_listed_name = result_set['cross_listed_name']
          cross_listed_names << cross_listed_name if cross_listed_name.present?
        end
      end
      expect(OecLegacy::Queries).to receive(:get_courses).with(nil, dept_name).exactly(1).times.and_return courses_query
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
      expect(OecLegacy::Queries).to receive(:get_courses).with(cross_listed_name).exactly(1).times.and_return result_set
    end
    expect(OecLegacy::Queries).to receive(:get_secondary_cross_listings).with([]).and_return []
  end

  context 'reading ANTHRO csv file' do
    subject { get_csv 'ANTHRO' }
    it {
      contain_exactly('COURSE_ID', '2015-B-02567')
    }
  end

  context 'reading MATH csv file' do
    subject { get_csv 'MATH' }
    it {
      contain_exactly('COURSE_ID', '2015-B-87672', '2015-B-54432', '2015-B-87675', '2015-B-54441', '2015-B-87673', '2015-B-87691')
    }
  end

  context 'reading POL SCI csv file' do
    subject { get_csv 'POL SCI' }
    it {
      contain_exactly('COURSE_ID', '2015-B-72198', '2015-B-72198')
    }
  end

  context 'reading STAT csv file' do
    subject { get_csv 'STAT' }
    it {
      contain_exactly('COURSE_ID', '2015-B-87672', '2015-B-54432', '2015-B-54441', '2015-B-72199', '2015-B-87691', '2015-B-87693')
    }
  end

  def get_csv(dept_name)
    export = OecLegacy::Courses.new(dept_name, 'tmp/oec').export
    CSV.read export[:filename]
  end

end
