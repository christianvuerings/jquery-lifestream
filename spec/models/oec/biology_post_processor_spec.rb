describe Oec::BiologyPostProcessor do

  let!(:csv_file_hash) { {} }

  before do
    export_dir = 'tmp/oec'
    dept_names = %w(BIOLOGY INTEGBI MCELLBI POL\ SCI)
    expect(Settings.oec).to receive(:departments).at_least(:once).and_return dept_names
    dept_names.each do |dept_name|
      courses_query = []
      CSV.read('fixtures/oec/courses_wrapper.csv').each_with_index do |row, index|
        if index > 0 && row[4] == dept_name
          courses_query << Oec::RowConverter.new(row).hashed_row
        end
      end
      expect(Oec::Queries).to receive(:get_courses).with(nil, dept_name).exactly(1).times.and_return courses_query
      export = Oec::Courses.new(dept_name, export_dir).export
      csv_file_hash[dept_name] = CSV.read export[:filename]
    end
    Oec::BiologyPostProcessor.new(export_dir, export_dir).post_process
  end

  context 'Biology 1A and 1B entries moved to MCELLBI and INTEGBI, respectively' do

    context 'reading BIOLOGY csv file' do
      subject { csv_file_hash['BIOLOGY'] }
      it {
        contain_exactly('COURSE_ID', '2015-B-87672')
      }
    end

    context 'reading INTEGBI csv file' do
      subject { csv_file_hash['INTEGBI'] }
      it {
        contain_exactly('COURSE_ID', '2015-B-54432', '2015-B-87675')
      }
    end

    context 'reading MCELLBI csv file' do
      subject { csv_file_hash['MCELLBI'] }
      it {
        contain_exactly('COURSE_ID', '2015-B-54441', '2015-B-87690', '2015-B-87693', '2015-B-87691')
      }
    end

    context 'reading POL SCI csv file' do
      subject { csv_file_hash['POL SCI'] }
      it {
        contain_exactly('COURSE_ID', '2015-B-72198')
      }
    end

  end
end
