describe OecLegacy::RowConverter do

  it 'should load valid row data to hash, despite warnings' do
    row = %w(2015-B-22303 course_name cross_listed_flag cross_listed_name\ (4567,\ 9876) dept_name catalog_id instruction_format section_num primary_secondary_cd ldap_uid sis_id first_name last_name email_address instructor_func blue_role evaluate dept_form evaluation_type modular_course start_date end_date)
    c = OecLegacy::RowConverter.new row
    h = c.hashed_row
    expect(h['term_yr']).to eq 2015
    expect(h['term_cd']).to eq 'B'
    expect(h['course_cntl_num']).to eq 22303
    expect(h['course_id']).to eq '2015-B-22303'
    expect(h['course_name']).to eq 'course_name'
    expect(h['cross_listed_flag']).to eq 'cross_listed_flag'
    expect(h['cross_listed_name']).to eq '4567, 9876'
    expect(h['course_title_short']).to eq 'cross_listed_name'
    expect(h['dept_name']).to eq 'dept_name'
    expect(h['catalog_id']).to eq 'catalog_id'
    expect(h['instruction_format']).to eq 'instruction_format'
    expect(h['section_num']).to eq 'section_num'
    expect(h['primary_secondary_cd']).to eq 'primary_secondary_cd'
    expect(h['ldap_uid']).to eq 'ldap_uid'
    expect(h['sis_id']).to eq 'sis_id'
    expect(h['first_name']).to eq 'first_name'
    expect(h['last_name']).to eq 'last_name'
    expect(h['email_address']).to eq 'email_address'
    expect(h['instructor_func']).to eq 'instructor_func'
    expect(h['blue_role']).to eq 'blue_role'
    expect(h['evaluate']).to eq 'evaluate'
    expect(h['dept_form']).to eq 'dept_form'
    expect(h['evaluation_type']).to eq 'evaluation_type'
    expect(h['modular_course']).to eq 'modular_course'
    expect(h['start_date']).to eq 'start_date'
    expect(h['end_date']).to eq 'end_date'
    # 'Invalid ldap_uid' and other warnings are expected
    expect(c.warnings).to_not be_empty
  end

  it 'should report invalid year, ccn, ldap and instructor_func' do
    row = %w(1999-B-1234567 course_name cross_listed_flag cross_listed_name\ (4567,\ 9876) dept_name catalog_id instruction_format section_num primary_secondary_cd 999999999999 sis_id first_name last_name email_address 5 blue_role evaluate dept_form evaluation_type modular_course start_date end_date)
    c = OecLegacy::RowConverter.new row
    expect(c.warnings).to have(4).items
    expect(c.warnings[0]).to include('term_yr', '1999')
    expect(c.warnings[1]).to include('course_cntl_num', '1234567')
    expect(c.warnings[2]).to include('ldap_uid', '999999999999')
    expect(c.warnings[3]).to include('instructor_func', '5')
  end

  it 'should not consider blank ldap and instructor_func as invalid' do
    row = %w(2015-b-12345 course_name cross_listed_flag cross_listed_name\ (4567,\ 9876) dept_name catalog_id instruction_format section_num primary_secondary_cd \  sis_id first_name last_name email_address \  blue_role evaluate dept_form evaluation_type modular_course start_date end_date)
    c = OecLegacy::RowConverter.new row
    expect(c.warnings).to be_empty
  end

end
