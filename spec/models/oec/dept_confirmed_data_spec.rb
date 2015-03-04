describe Oec::DeptConfirmedData do

  it 'should load all courses_confirmed.csv files when no departments specified' do
    actual_csv_files = %w(BIOLOGY POL\ SCI STAT)
    missing_csv_files = %w(FOO BAZ)
    confirmed_data = Oec::DeptConfirmedData.new('fixtures/oec', actual_csv_files + missing_csv_files)
    confirmed_data_hash = confirmed_data.confirmed_data_per_dept
    confirmed_data_hash.keys.should match_array actual_csv_files
    confirmed_data.warnings_per_dept.length.should eq 4
    confirmed_data.warnings_per_dept['POL SCI'].length.should eq 2
    confirmed_data.warnings_per_dept['STAT'].length.should eq 3
  end

  it 'should not load the STAT_courses_confirmed.csv because it was not requested' do
    csv_files = %w(BIOLOGY POL\ SCI)
    dept_set = Oec::DepartmentRegistry.new csv_files
    confirmed_data = Oec::DeptConfirmedData.new('fixtures/oec', dept_set)
    confirmed_data.confirmed_data_per_dept.keys.should match_array csv_files
    # Expect report of missing MCELLBI and INTEGBI files because BIOLOGY was requested
    confirmed_data.warnings_per_dept.length.should eq 3
    confirmed_data.warnings_per_dept['POL SCI'].length.should eq 2
  end

end

