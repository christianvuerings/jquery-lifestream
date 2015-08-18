describe Oec::CourseCode do

  before do
    Oec::CourseCode.create(dept_name: 'A,RESEC', catalog_id: '', dept_code: 'MBARC', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'BIOLOGY', catalog_id: '1A', dept_code: 'IMMCB', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'BIOLOGY', catalog_id: '1AL', dept_code: 'IMMCB', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'BIOLOGY', catalog_id: '1B', dept_code: 'IBIBI', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'BIOLOGY', catalog_id: '1BL', dept_code: 'IBIBI', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'CATALAN', catalog_id: '', dept_code: 'LPSPP', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'CHEM', catalog_id: '', dept_code: 'CCHEM', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'INTEGBI', catalog_id: '', dept_code: 'IBIBI', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'MCELLBI', catalog_id: '', dept_code: 'IMMCB', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'PORTUG', catalog_id: '', dept_code: 'LPSPP', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'SPANISH', catalog_id: '', dept_code: 'LPSPP', include_in_oec: true)
    Oec::CourseCode.create(dept_name: 'SPANISH', catalog_id: '99', dept_code: 'LPSPP', include_in_oec: false)
  end

  it 'should find course codes for a single department' do
    course_codes = Oec::CourseCode.where(dept_code: 'CCHEM').to_a
    expect(course_codes).to have(1).items
    expect(course_codes.first.dept_name).to eq 'CHEM'
    expect(course_codes.first.catalog_id).to eq ''
  end

  it 'should accept department names with weird characters' do
    course_codes = Oec::CourseCode.where(dept_name: 'A,RESEC').to_a
    expect(course_codes).to have(1).items
  end

  it 'should find course codes assigned to department by specific catalog id' do
    course_codes = Oec::CourseCode.where(dept_code: 'IBIBI').to_a
    expect(course_codes).to have(3).items
    expect(course_codes.map &:dept_name).to match_array %w(BIOLOGY BIOLOGY INTEGBI)
    expect(course_codes.map &:catalog_id).to match_array ['1B', '1BL', '']
  end

  it 'should find course codes listed under subdepartments' do
    course_codes = Oec::CourseCode.where(dept_code: 'LPSPP').to_a
    expect(course_codes).to have(4).items
    expect(course_codes.map &:dept_name).to match_array %w(CATALAN PORTUG SPANISH SPANISH)
    expect(course_codes.map &:catalog_id).to match_array ['', '', '', '99']
  end

  it 'should allow omission of non-included course codes' do
    course_codes = Oec::CourseCode.where(dept_code: 'LPSPP', include_in_oec: true).to_a
    expect(course_codes).to have(3).items
    expect(course_codes.map &:dept_name).to match_array %w(CATALAN PORTUG SPANISH)
    expect(course_codes.map &:catalog_id).to match_array ['', '', '']
  end

  it 'should allow course-code-specific mappings to coexist with wildcard blank mapping' do
    Oec::CourseCode.create(dept_name: 'SPANISH', catalog_id: '399', dept_code: 'SHIST', include_in_oec: true)
    history_course_codes = Oec::CourseCode.where(dept_code: 'SHIST').to_a
    expect(history_course_codes).to have(1).items
    span_port_course_codes = Oec::CourseCode.where(dept_code: 'LPSPP').to_a
    expect(span_port_course_codes).to have(4).items
  end

  it 'should not allow duplicate course-code-specific mappings' do
    expect { Oec::CourseCode.create(dept_name: 'BIOLOGY', catalog_id: '1A', dept_code: 'SHIST', include_in_oec: true) }.to raise_error ActiveRecord::RecordNotUnique
  end

  it 'should not allow duplicate wildcard blank mappings' do
    expect { Oec::CourseCode.create(dept_name: 'SPANISH', catalog_id: '', dept_code: 'SHIST', include_in_oec: true) }.to raise_error ActiveRecord::RecordNotUnique
  end

end
