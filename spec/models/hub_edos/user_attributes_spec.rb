describe HubEdos::UserAttributes do

  let(:user_id) { '61889' }
  let(:fake_student_proxy) { HubEdos::Student.new(user_id: user_id) }
  before { allow(HubEdos::Student).to receive(:new).and_return fake_student_proxy }

  subject { HubEdos::UserAttributes.new(user_id: user_id).get }

  it 'should provide the converted person data structure' do
    expect(subject[:ldap_uid]).to eq '61889'
    expect(subject[:student_id]).to eq '11667051'
    expect(subject[:first_name]).to eq 'Osk'
    expect(subject[:last_name]).to eq 'Bear'
    expect(subject[:person_name]).to eq 'Osk Bear'
    expect(subject[:email_address]).to eq 'oski@berkeley.edu'
    expect(subject[:official_bmail_address]).to eq 'oski@berkeley.edu'
    expect(subject[:names]).to be
    expect(subject[:addresses]).to be
  end

  context 'role transformation' do
    before do
      fake_student_proxy.override_json { |json| json['studentResponse']['students']['students'][0]['affiliations'] = affiliations }
    end

    context 'undergraduate student' do
      let(:affiliations) do
        [{
          'type' => {
            'code' => 'UNDERGRAD',
            'description' => 'Undergraduate'
          },
          'statusCode' => 'ACT',
          'statusDescription' => 'Active',
          'fromDate' => '2014-05-15'
        }]
      end
      it 'should return undergraduate attributes' do
        expect(subject[:roles][:student]).to eq true
        expect(subject[:ug_grad_flag]).to eq 'U'
      end
    end

    context 'graduate student' do
      let(:affiliations) do
        [{
          'type' => {
            'code' => 'GRAD',
            'description' => 'Graduate'
          },
          'statusCode' => 'ACT',
          'statusDescription' => 'Active',
          'fromDate' => '2014-05-15'
        }]
      end
      it 'should return graduate attributes' do
        expect(subject[:roles][:student]).to eq true
        expect(subject[:ug_grad_flag]).to eq 'G'
      end
    end

    context 'no affiliations' do
      let(:affiliations) { [] }
      it 'should return no student attributes' do
        expect(subject[:roles]).to eq({})
        expect(subject[:ug_grad_flag]).to be_nil
      end
    end
  end
end
