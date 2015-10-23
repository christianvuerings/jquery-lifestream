describe Berkeley::GradeOptions do
  subject {Berkeley::GradeOptions.grade_option_for_enrollment(credit_code, pnp_flag)}

  [nil, '  ', 'N'].each do |pnp_cd|
    context "when P/NP flag is '#{pnp_cd}'" do
      let(:pnp_flag) {pnp_cd}
      [nil, 'PF', 'SF', '2T', '3T', 'TT', 'PT', 'ST'].each do |cred_cd|
        context "when #{cred_cd} credit code" do
          let(:credit_code) {cred_cd}
          it {should eq 'Letter'}
        end
      end
      # WARNING: The registrar documentation on "PF" and "PN" seems to have them swapped.
      ['PN'].each do |cred_cd|
        context "when #{cred_cd} credit code" do
          let(:credit_code) {cred_cd}
          it {should eq 'P/NP'}
        end
      end
      ['SU'].each do |cred_cd|
        context "when #{cred_cd} credit code" do
          let(:credit_code) {cred_cd}
          it {should eq 'S/U'}
        end
      end
      ['T1', 'T2', 'T3', 'TP', 'TS', 'TX'].each do |cred_cd|
        context "when #{cred_cd} credit code" do
          let(:credit_code) {cred_cd}
          it {should eq 'IP'}
        end
      end
    end
  end

  context 'when P/NP flag is Y' do
    let(:pnp_flag) {'Y'}
    [nil, 'PF', 'PN'].each do |cred_cd|
      context "when #{cred_cd} credit code" do
        let(:credit_code) {cred_cd}
        it {should eq 'P/NP'}
      end
    end
    ['SF', 'SU'].each do |cred_cd|
      context "when #{cred_cd} credit code" do
        let(:credit_code) {cred_cd}
        it {should eq 'S/U'}
      end
    end
    # We have no data for these.
    ['2T', '3T', 'TT', 'PT', 'ST', 'T1', 'T2', 'T3', 'TP', 'TS', 'TX'].each do |cred_cd|
      context "when #{cred_cd} credit code" do
        let(:credit_code) {cred_cd}
        it {should eq ''}
      end
    end
  end

end
