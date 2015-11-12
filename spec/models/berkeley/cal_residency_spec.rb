describe Berkeley::CalResidency do
  let(:db_row) do
    {
      'ldap_uid' => random_id,
      'student_id' => random_id,
      'fee_resid_cd' => fee_resid_cd,
      'admit_special_pgm_grp' => admit_special_pgm_grp
    }
  end
  let(:admit_special_pgm_grp) { nil }
  subject { Berkeley::CalResidency.california_residency_from_campus_row(db_row) }

  context 'no student record for the current semester' do
    let(:fee_resid_cd) { nil }
    it { should be_nil }
  end

  context 'exempt' do
    let(:fee_resid_cd) { 'E' }
    it { should be_nil }
  end

  context 'code " "' do
    let(:fee_resid_cd) { ' ' }
    it { should eq({
      summary: 'No SLR submitted',
      explanation: Berkeley::CalResidency::RESIDENCY_UNSTARTED_MESSAGE,
      needsAction: true
    }) }
  end

  context 'code "S"' do
    let(:fee_resid_cd) { ' ' }
    it { should eq({
      summary: 'No SLR submitted',
      explanation: Berkeley::CalResidency::RESIDENCY_UNSTARTED_MESSAGE,
      needsAction: true
    }) }
  end

  context 'code "P"' do
    let(:fee_resid_cd) { 'P' }
    it { should eq({
      summary: 'Case pending',
      explanation: Berkeley::CalResidency::RESIDENCY_INCOMPLETE_MESSAGE,
      needsAction: true
    }) }
  end

  context 'code "1"' do
    let(:fee_resid_cd) { '1' }
    it { should eq({
      summary: 'SLR started but not completed',
      explanation: Berkeley::CalResidency::RESIDENCY_INCOMPLETE_MESSAGE,
      needsAction: true
    }) }
  end

  context 'code "2"' do
    let(:fee_resid_cd) { '2' }
    it { should eq({
      summary: 'SLR submitted but documentation pending',
      explanation: Berkeley::CalResidency::RESIDENCY_INCOMPLETE_MESSAGE,
      needsAction: true
    }) }
  end

  context 'code "R"' do
    let(:fee_resid_cd) { 'R' }
    it { should eq({
      summary: 'Resident',
      explanation: '',
      needsAction: false
    }) }
  end

  context 'code "N"' do
    let(:fee_resid_cd) { 'N' }
    it { should eq({
      summary: 'Non-Resident',
      explanation: Berkeley::CalResidency::RESIDENCY_COMPLETE_MESSAGE,
      needsAction: false
    }) }
  end

  context 'code "L"' do
    let(:fee_resid_cd) { 'L' }
    it { should eq({
      summary: 'Provisional resident',
      explanation: Berkeley::CalResidency::RESIDENCY_COMPLETE_MESSAGE,
      needsAction: false
    }) }
  end

end
