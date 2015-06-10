describe Oec::Queries do

  let(:test_ccn) do
    Oec::Queries.test_data? ? '7309' : '7203'
  end
  before do
    term = OpenStruct.new({ :year => 2015, :code => 'B' })
    expect(Settings.oec).to receive(:current_terms_codes).at_most(10).times.and_return([ term ])
  end

  context 'limiting query to OEC departments' do
    subject { CampusOracle::Connection.depts_clause('c', Settings.oec.departments) }
    it { subject.should include('STAT', 'SPANISH', 'PORTUG', 'CHEM') }
    it { subject.should_not include 'NOT' }
  end

  context 'excluding OEC departments' do
    subject { CampusOracle::Connection.depts_clause('c', Settings.oec.departments, false) }
    it { subject.should include('STAT', 'SPANISH', 'PORTUG', 'CHEM') }
    it { subject.should include 'NOT IN' }
  end

  context 'looking up students' do
    let(:all_students) { Oec::Queries.get_all_students [test_ccn] }
    it { expect(all_students).to_not be_nil }
    it { expect(all_students[0]['ldap_uid']).to_not be_nil }
  end

  context 'looking up secondary cross listings of empty list' do
    subject { Oec::Queries.get_secondary_cross_listings }
    it { should be_empty }
  end

  context 'looking up courses', :testext => true do
    subject { Oec::Queries.get_courses(nil, 'MATH') }
    it { should_not be_nil }
    it { subject[0]['course_id'].should_not be_nil }
  end

  context 'looking up courses with crosslistings', :testext => true do
    subject { Oec::Queries.get_courses '7309, 7366' }
    it { should_not be_nil }
  end

  context 'looking up students in 2000 courses', :testext => true do
    subject { Oec::Queries.get_all_students(('7000'..'9000').to_a) }
    it { should_not be_nil }
    it { subject[0]['ldap_uid'].should_not be_nil }
  end

  context 'looking up course_students' do
    subject { Oec::Queries.get_all_course_students [test_ccn] }
    it { should_not be_nil }
    it { subject[0]['ldap_uid'].should_not be_nil }
  end

end
