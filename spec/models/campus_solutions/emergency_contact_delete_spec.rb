describe CampusSolutions::EmergencyContactDelete do

  let(:user_id) { '12345' }

  context 'deleting an emergency contact' do
    let(:params) { {} }
    let(:proxy) { CampusSolutions::EmergencyContactDelete.new(fake: true, user_id: user_id, params: params) }

    context 'converting params to Campus Solutions field names' do
      let(:params) { {
        bogus: 'foo',
        contactName: 'Joe'
      } }
      subject {
        proxy.construct_cs_post(params)
      }
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject[:query][:CONTACT_NAME]).to eq 'Joe'
        expect(subject[:query].keys.length).to eq 2
      end
    end

    context 'performing a delete' do
      let(:params) { {
        contactName: 'Joe'
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
      # CS server will reject post unless data has changed, so make some key fields unique with timestamp
      contactName: "Tester Friend #{user_id}",
      isSameAddressEmpl: 'N',
      isPrimaryContact: 'N',
      country: 'USA',
      address1: "Lane #{DateTime.now.to_i}",
      address2: 'peters road',
      address3: 'estella st',
      address4: 'fourth field lane',
      city: 'ventura',
      num1: '1',
      num2: '2',
      houseType: 'AB',
      addrField1: 'AV',
      addrField2: 'L2',
      addrField3: 'L3',
      county: 'Alameda',
      state: 'CA',
      postal: '93001',
      geoCode: '',
      inCityLimit: 'N',
      countryCode: '',
      phone: '805/658-4588',
      relationship: 'SP',
      isSamePhoneEmpl: 'N',
      addressType: 'HOME',
      phoneType: 'HOME',
      extension: '123',
      emailAddr: 'foo@foo.com'
    } }
    before {
      CampusSolutions::EmergencyContact.new(fake: false, user_id: user_id, params: create_params).get
    }

    let(:proxy) { CampusSolutions::EmergencyContactDelete.new(fake: false, user_id: user_id, params: params) }
    subject { proxy.get }

    context 'a successful delete' do
      let(:params) { {
        contactName: "Tester Friend #{user_id}"
      } }
      context 'performing a real delete' do
        it_behaves_like 'a proxy that got data successfully'
      end
    end

  end
end
