describe CampusSolutions::EmergencyContact do

  let(:user_id) { '12345' }

  context 'post' do
    let(:params) { {} }
    let(:proxy) { CampusSolutions::EmergencyContact.new(fake: true, user_id: user_id, params: params) }

    context 'filtering out fields not on the whitelist' do
      let(:params) { {
        bogus: 1,
        invalid: 2,
        contactName: 'Joe'
      } }
      subject { proxy.filter_updateable_params(params) }
      it 'should strip out invalid fields' do
        expect(subject.keys.length).to eq 28
        expect(subject[:bogus]).to be_nil
        expect(subject[:invalid]).to be_nil
        expect(subject[:contactName]).to eq 'Joe'
      end
    end

    context 'converting params to Campus Solutions field names' do
      let(:params) { {
        contactName: 'Joe',
        isSameAddressEmpl: 'N'
      } }
      subject {
        result = proxy.construct_cs_post(params)
        MultiXml.parse(result)['UC_EMER_CNTCT']
      }
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject['SAME_ADDRESS_EMPL']).to eq 'N'
        expect(subject['CONTACT_NAME']).to eq 'Joe'
      end
    end

    context 'performing a post' do
      let(:params) { {
        contactName: 'Joe',
        isSameAddressEmpl: 'N'
      } }
      subject {
        proxy.get
      }
      it_should_behave_like 'a simple proxy that returns errors'
      it_behaves_like 'a proxy that properly observes the profile feature flag'
      it_behaves_like 'a proxy that got data successfully'
    end
  end

  context 'with a real external service', :testext => true do
    let(:params) { {
      # CS server will reject post unless data has changed, so make some key fields unique with timestamp
      contactName: "Tester #{DateTime.now.to_i}",
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
    let(:proxy) { CampusSolutions::EmergencyContact.new(fake: false, user_id: user_id, params: params) }

    context 'performing a real post' do
      subject {
        proxy.get
      }
      it_should_behave_like 'a simple proxy that returns errors'
      it_behaves_like 'a proxy that got data successfully'
    end
  end
end
