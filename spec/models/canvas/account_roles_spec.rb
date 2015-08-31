describe Canvas::AccountRoles do

  subject { Canvas::AccountRoles.new(account_id: account_id, fake: true)}

  let(:department_account_id) {128847}
  let(:project_account_id) {1379095}

  shared_examples 'a bCourses account' do
    it 'includes account-level roles in the raw proxy call' do
      result = subject.roles_list
      expect(result.select {|r| r['base_role_type'] == 'AccountMembership'}).to be_present
    end
    it 'omits account-level roles in the course roles list' do
      result = subject.defined_course_roles
      expect(result.select {|r| r['base_role_type'] == 'AccountMembership'}).to be_empty
    end
  end

  context 'when an academic department subaccount' do
    let(:account_id) {department_account_id}
    it_behaves_like 'a bCourses account'
    it 'has the extra official course roles' do
      result = subject.defined_course_roles
      labels = result.collect {|r| r['label']}
      expect(labels).to include('Lead TA', 'Reader', 'Waitlist Student')
    end
  end
  context 'when a project sites account' do
    let(:account_id) {project_account_id}
    it_behaves_like 'a bCourses account'
    it 'has the extra project site roles' do
      result = subject.defined_course_roles
      labels = result.collect {|r| r['label']}
      expect(labels).to include('Member', 'Owner', 'Maintainer')
    end
  end

end
