describe Oec::Queries do

  let(:term_code) { '2015-B' }

  before do
    term = OpenStruct.new({ :year => 2015, :code => 'B' })
    expect(Settings.oec).to receive(:current_terms_codes).at_most(10).times.and_return([ term ])
  end

  context 'department-specific queries' do
    subject { Oec::Queries.depts_clause('c', course_codes) }

    context 'limiting query by department code' do
      let(:course_codes) do
        [
          Oec::CourseCode.new(dept_name: 'CATALAN', catalog_id: nil, dept_code: 'LPSPP', include_in_oec: true),
          Oec::CourseCode.new(dept_name: 'PORTUG', catalog_id: nil, dept_code: 'LPSPP', include_in_oec: true),
          Oec::CourseCode.new(dept_name: 'SPANISH', catalog_id: nil, dept_code: 'LPSPP', include_in_oec: true),
          Oec::CourseCode.new(dept_name: 'ILA', catalog_id: nil, dept_code: 'LPSPP', include_in_oec: false)
        ]
      end
      it { should include("(c.dept_name = 'CATALAN')", "(c.dept_name = 'PORTUG')", "(c.dept_name = 'SPANISH')") }
      it { should_not include "(c.dept_name = 'ILA')" }
      it { should_not include 'NOT' }
    end

    context 'limiting query by course code' do
      let(:course_codes) do
        [
          Oec::CourseCode.new(dept_name: 'INTEGBI', catalog_id: nil, dept_code: 'IBIBI', include_in_oec: true),
          Oec::CourseCode.new(dept_name: 'BIOLOGY', catalog_id: '1B', dept_code: 'IBIBI', include_in_oec: true),
          Oec::CourseCode.new(dept_name: 'BIOLOGY', catalog_id: '1BL', dept_code: 'IBIBI', include_in_oec: true)
        ]
      end
      it { should include "(c.dept_name = 'INTEGBI')", "(c.dept_name = 'BIOLOGY' and c.catalog_id IN (" , "'1B'", "'1BL'" }
      it { should_not include 'NOT' }
    end
  end

  context 'looking up secondary cross listings of empty list' do
    subject { Oec::Queries.get_secondary_cross_listings(term_code, []) }
    it { should be_empty }
  end

  context 'looking up courses', :testext => true do
    subject do
      Oec::Queries.courses_for_codes(
        term_code,
        [Oec::CourseCode.new(dept_name: 'MATH', catalog_id: nil, dept_code: 'PMATH', include_in_oec: true)]
      )
    end
    it { should_not be_nil }
    it { subject[0]['course_id'].should_not be_nil }
  end

  context 'looking up courses with crosslistings', :testext => true do
    subject { Oec::Queries.courses_for_cntl_nums(term_code, '7309, 7366') }
    it { should_not be_nil }
  end

end
