require 'spec_helper'

describe CampusSolutions::EmergencyContact do

  context 'post' do
    let(:params) { {} }
    let(:proxy) { CampusSolutions::EmergencyContact.new(fake: true, user_id: random_id, params: params) }

    context 'filtering out fields not on the whitelist' do
      let(:params) { {
        bogus: 1,
        invalid: 2,
        contactName: 'Joe'
      } }
      subject { proxy.filter_updateable_params(params) }
      it 'should strip out invalid fields' do
        expect(subject.keys.length).to eq 1
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
      it 'should make a successful post' do
        expect(subject[:statusCode]).to eq 200
        expect(subject[:feed][:status]).to be
      end
    end
  end

  context 'with a real external service', :testext => true do
    let(:params) { {
      contactName: 'TEST',
      isSameAddressEmpl: 'N',
      isPrimaryContact: 'Y',
      country: 'USA',
      address1: 'lane7',
      address2: 'peters road',
      address3: 'estella st',
      address4: 'fourth field lane',
      city: 'ventura',
      num1: '1',
      num2: '2',
      houseType: 'AB',
      addrField1: 'L1',
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
      phoneType: 'CELL',
      extension: '123',
      emailAddr: 'foo@foo.com'
    } }
    let(:proxy) { CampusSolutions::EmergencyContact.new(fake: false, user_id: random_id, params: params) }

    context 'performing a real post' do
      subject {
        proxy.get
      }
      it_should_behave_like 'a simple proxy that returns errors'
      it 'should make a successful REAL post' do
        expect(subject[:statusCode]).to eq 200
        expect(subject[:feed][:status]).to be
      end
    end
  end
end
