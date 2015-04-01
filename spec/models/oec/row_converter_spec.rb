describe Oec::RowConverter do

  it 'should load valid row data to hash, despite warnings' do
    row = %w(2015-B-22303 COURSE_NAME CROSS_LISTED_FLAG CROSS_LISTED_NAME\ (4567,\ 9876) DEPT_NAME CATALOG_ID INSTRUCTION_FORMAT SECTION_NUM PRIMARY_SECONDARY_CD LDAP_UID FIRST_NAME LAST_NAME EMAIL_ADDRESS INSTRUCTOR_FUNC BLUE_ROLE EVALUATE DEPT_FORM EVALUATION_TYPE MODULAR_COURSE START_DATE END_DATE)
    c = Oec::RowConverter.new row
    h = c.hashed_row
    expect(h['term_yr']).to eq 2015
    expect(h['term_cd']).to eq 'B'
    expect(h['course_cntl_num']).to eq 22303
    expect(h['course_id']).to eq '2015-B-22303'
    expect(h['course_name']).to eq 'COURSE_NAME'
    expect(h['cross_listed_flag']).to eq 'CROSS_LISTED_FLAG'
    expect(h['cross_listed_name']).to eq '4567, 9876'
    expect(h['course_title_short']).to eq 'CROSS_LISTED_NAME'
    expect(h['dept_name']).to eq 'DEPT_NAME'
    expect(h['catalog_id']).to eq 'CATALOG_ID'
    expect(h['instruction_format']).to eq 'INSTRUCTION_FORMAT'
    expect(h['section_num']).to eq 'SECTION_NUM'
    expect(h['primary_secondary_cd']).to eq 'PRIMARY_SECONDARY_CD'
    expect(h['ldap_uid']).to eq 'LDAP_UID'
    expect(h['first_name']).to eq 'FIRST_NAME'
    expect(h['last_name']).to eq 'LAST_NAME'
    expect(h['email_address']).to eq 'EMAIL_ADDRESS'
    expect(h['instructor_func']).to eq 'INSTRUCTOR_FUNC'
    expect(h['blue_role']).to eq 'BLUE_ROLE'
    expect(h['evaluate']).to eq 'EVALUATE'
    expect(h['dept_form']).to eq 'DEPT_FORM'
    expect(h['evaluation_type']).to eq 'EVALUATION_TYPE'
    expect(h['modular_course']).to eq 'MODULAR_COURSE'
    expect(h['start_date']).to eq 'START_DATE'
    expect(h['end_date']).to eq 'END_DATE'
    # 'Invalid ldap_uid' and other warnings are expected
    expect(c.warnings).to_not be_empty
  end

  it 'should report invalid year, ccn, ldap and instructor_func' do
    row = %w(1999-B-1234567 COURSE_NAME CROSS_LISTED_FLAG CROSS_LISTED_NAME\ (4567,\ 9876) DEPT_NAME CATALOG_ID INSTRUCTION_FORMAT SECTION_NUM PRIMARY_SECONDARY_CD 21 FIRST_NAME LAST_NAME EMAIL_ADDRESS 5 BLUE_ROLE EVALUATE DEPT_FORM EVALUATION_TYPE MODULAR_COURSE START_DATE END_DATE)
    c = Oec::RowConverter.new row
    expect(c.warnings).to have(4).items
    expect(c.warnings[0]).to include('term_yr', '1999')
    expect(c.warnings[1]).to include('course_cntl_num', '1234567')
    expect(c.warnings[2]).to include('ldap_uid', '21')
    expect(c.warnings[3]).to include('instructor_func', '5')
  end

  it 'should not consider blank ldap and instructor_func as invalid' do
    row = %w(2015-B-12345 COURSE_NAME CROSS_LISTED_FLAG CROSS_LISTED_NAME\ (4567,\ 9876) DEPT_NAME CATALOG_ID INSTRUCTION_FORMAT SECTION_NUM PRIMARY_SECONDARY_CD \  FIRST_NAME LAST_NAME EMAIL_ADDRESS \  BLUE_ROLE EVALUATE DEPT_FORM EVALUATION_TYPE MODULAR_COURSE START_DATE END_DATE)
    c = Oec::RowConverter.new row
    expect(c.warnings).to be_empty
  end

end
