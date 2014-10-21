describe Oec::CoursesWrapper do

  before(:suite) do
    dept_names = %w(BIOLOGY INTEGBI MCELLBI 'POL SCI')
    expect(Settings.oec).to receive(:departments).exactly(1).and_return dept_names
    dept_names.each do |dept_name|
      courses_query = []
      CSV.read('fixtures/oec/courses_wrapper.csv').each_with_index do |row, index|
        if index > 0 && row[4] == dept_name
          courses_query << OecSpecHelper.convert_csv_row_to_oec_result(row)
        end
      end
      expect(Oec::Queries).to receive(:get_courses).with(nil, dept_name).exactly(1).times.and_return(courses_query)
    end
    @timestamp = Oec::CoursesWrapper.new.create_csv_file_per_dept
  end

  context 'Biology 1A and 1B entries moved to MCELLBI and INTEGBI, respectively' do

    context 'reading BIOLOGY csv file' do
      subject { OecSpecHelper.get_csv('BIOLOGY', @timestamp) }
      it {
        contain_exactly('COURSE_ID', '2013-D-87672')
      }
    end

    context 'reading INTEGBI csv file' do
      subject { OecSpecHelper.get_csv('INTEGBI', @timestamp) }
      it {
        contain_exactly('COURSE_ID', '2013-D-54432', '2013-D-87675')
      }
    end

    context 'reading MCELLBI csv file' do
      subject { OecSpecHelper.get_csv('MCELLBI', @timestamp) }
      it {
        contain_exactly('COURSE_ID', '2013-D-54441', '2013-D-87690', '2013-D-87693', '2013-D-87691')
      }
    end

    context 'reading POL SCI csv file' do
      subject { OecSpecHelper.get_csv('POL SCI', @timestamp) }
      it {
        contain_exactly('COURSE_ID', '2013-D-72198')
      }
    end

  end

end
