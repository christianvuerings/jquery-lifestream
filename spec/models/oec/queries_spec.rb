describe Oec::Queries do

  let(:term_code) { '2015-B' }
  let(:test_ccn) { Oec::Queries.test_data? ? '7309' : '7203' }

  before do
    term = OpenStruct.new({ :year => 2015, :code => 'B' })
    expect(Settings.oec).to receive(:current_terms_codes).at_most(10).times.and_return([ term ])
  end

  context 'department-specific queries' do
    subject { Oec::Queries.depts_clause('c', course_codes, import_all) }
    let(:import_all) { false }

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

      context 'with import_all flag' do
        let(:import_all) { true }
        it { should include "(c.dept_name = 'ILA')" }
      end
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

  def expect_results(keys, opts={})
    subject.each do |result|
      if opts[:allow_nil]
        keys.each { |key| expect(result).to have_key key }
      elsif keys.is_a? Hash
        keys.each { |key, value| expect(result[key]).to eq value }
      else
        keys.each { |key| expect(result[key]).to be_present }
      end
    end
  end

  shared_examples 'expected result structure' do
    it 'should include correct term values' do
      term_yr, term_cd = term_code.split '-'
      expect_results({'term_yr' => term_yr, 'term_cd' => term_cd})
    end
    it 'should include course catalog data' do
      expect_results(
        %w(course_cntl_num course_id course_name dept_name catalog_id instruction_format section_num primary_secondary_cd),
        allow_nil: false
      )
      expect_results(%w(course_title_short cross_listed_flag), allow_nil: true)
    end
    it 'should include instructor data' do
      expect_results(%w(ldap_uid sis_id first_name last_name email_address instructor_func affiliations), allow_nil: true)
    end
    it 'should include hard-coded values' do
      expect_results({'blue_role' => '23'})
    end
    it 'should include subquery-generated values' do
      expect_results(%w(enrollment_count), allow_nil: false)
      expect_results(%w(cross_listed_ccns co_scheduled_ccns), allow_nil: true)
    end
  end

  context 'course lookup by code', testext: true do
    subject do
      Oec::Queries.courses_for_codes(
        term_code,
        [Oec::CourseCode.new(dept_name: 'MATH', catalog_id: nil, dept_code: 'PMATH', include_in_oec: true)]
      )
    end
    include_examples 'expected result structure'
  end

  context 'a department not participating in OEC', testext: true do
    subject do
      Oec::Queries.courses_for_codes(
        term_code,
        [Oec::CourseCode.new(dept_name: 'FRENCH', catalog_id: nil, dept_code: 'HFREN', include_in_oec: false)],
        import_all
      )
    end

    context 'without import_all flag' do
      let (:import_all) { false }
      it { should be_empty }
    end

    context 'with import_all flag' do
      let (:import_all) { true }
      include_examples 'expected result structure'
    end
  end

  context 'course lookup by ccn', testext: true do
    let(:ccns) { %w(53507 53513) }
    subject { Oec::Queries.courses_for_cntl_nums(term_code, ccns) }
    include_examples 'expected result structure'
    it 'returns the right courses' do
      expect(subject).to have(2).items
      expect(subject.map { |row| row['course_cntl_num'] }).to match_array ccns
    end
  end

  context 'crosslisting and room share lookup', testext: true do
    let(:ccns) { %w(54041 54044) }
    let(:ccn_aggregates) { [ '54041,54320', '54044,54323' ] }
    subject { Oec::Queries.courses_for_cntl_nums(term_code, ccns) }
    it 'returns correct aggregated ccns' do
      expect(subject.map { |row| row['cross_listed_ccns'] }).to match_array ccn_aggregates
      expect(subject.map { |row| row['co_scheduled_ccns'] }).to match_array ccn_aggregates
    end
  end

  let(:students_query) { Oec::Queries.students_for_cntl_nums(term_code, [test_ccn]) }

  context 'looking up students' do
    it 'contains expected result structure' do
      expect(students_query).not_to be_empty
      students_query.each do |row|
        expect(row['first_name']).to be_present
        expect(row['last_name']).to be_present
        expect(row['email_address']).to be_present
        expect(row['ldap_uid']).to be_present
        expect(row['sis_id']).to be_present
      end
    end
  end

  let(:enrollments_query) { Oec::Queries.enrollments_for_cntl_nums(term_code, [test_ccn]) }

  context 'looking up enrollments' do
    it 'contains expected result structure' do
      expect(enrollments_query).not_to be_empty
      enrollments_query.each do |row|
        expect(row['ldap_uid']).to be_present
        expect(row['course_id']).to eq "#{term_code}-#{test_ccn.rjust(5, '0')}"
      end
    end

    it 'returns matching student and enrollment data' do
      expect(enrollments_query.map { |row| row['ldap_uid'] }).to match_array(students_query.map { |row| row['ldap_uid'] })
    end
  end

end
