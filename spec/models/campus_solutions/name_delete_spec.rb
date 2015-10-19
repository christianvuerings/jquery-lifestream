describe CampusSolutions::NameDelete do

  let(:user_id) { '12345' }

  context 'deleting name' do
    let(:params) { {} }
    let(:proxy) { CampusSolutions::NameDelete.new(fake: true, user_id: user_id, params: params) }

    context 'converting params to Campus Solutions field names' do
      let(:params) { {
        bogus: 'foo',
        type: 'CAMP'
      } }
      subject {
        proxy.construct_cs_post(params)
      }
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject[:query][:TYPE]).to eq 'CAMP'
        expect(subject[:query].keys.length).to eq 2
      end
    end

    context 'performing a delete' do
      let(:params) { {
        type: 'CAMP'
      } }
      subject {
        proxy.get
      }
      it_should_behave_like 'a simple proxy that returns errors'
      it_behaves_like 'a proxy that properly observes the profile feature flag'
      it_behaves_like 'a proxy that got data successfully'
    end
  end

  context 'with a real external service', testext: true do
    let(:create_params) { {
      type: 'LEG',
      firstName: 'Joey',
      lastName: 'Test',
      initials: 'JT',
      prefix: 'Mr',
      suffix: '',
      royalPrefix: '',
      royalSuffix: '',
      title: '',
      middleName: '',
      secondLastName: '',
      ac: '',
      preferredFirstName: '',
      partnerLastName: '',
      partnerRoyalPrefix: '',
      lastNamePrefNld: ''
    } }
    before {
      CampusSolutions::PersonName.new(fake: false, user_id: user_id, params: create_params).get
    }

    let(:proxy) { CampusSolutions::NameDelete.new(fake: false, user_id: user_id, params: params) }
    subject { proxy.get }

    context 'a successful delete' do
      let(:params) { {
        type: 'LEG'
      } }
      context 'performing a real delete' do
        it_behaves_like 'a proxy that got data successfully'
      end
    end

  end
end
