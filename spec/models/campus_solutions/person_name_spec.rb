require 'spec_helper'

describe CampusSolutions::PersonName do

  context 'post' do
    let(:params) { {} }
    let(:proxy) { CampusSolutions::PersonName.new(fake: true, user_id: random_id, params: params) }

    context 'filtering out fields not on the whitelist' do
      let(:params) { {
        bogus: 1,
        invalid: 2,
        firstName: 'Joe'
      } }
      subject { proxy.filter_updateable_params(params) }
      it 'should strip out invalid fields' do
        expect(subject.keys.length).to eq 1
        expect(subject[:bogus]).to be_nil
        expect(subject[:invalid]).to be_nil
        expect(subject[:firstName]).to eq 'Joe'
      end
    end

    context 'converting params to Campus Solutions field names' do
      let(:params) { {
        type: 'LEG',
        firstName: 'Joe'
      } }
      subject {
        result = proxy.construct_cs_post(params)
        MultiXml.parse(result)['NAMES']
      }
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject['NAME_TYPE']).to eq 'LEG'
        expect(subject['FIRST_NAME']).to eq 'Joe'
      end
    end

    context 'performing a post' do
      let(:params) { {
        type: 'LEG',
        firstName: 'Joe'
      } }
      subject {
        proxy.get
      }
      it_should_behave_like 'a simple proxy that returns errors'
      it 'should make a successful post' do
        expect(subject[:statusCode]).to eq 200
        expect(subject[:feed][:status]).to be
      end
    end
  end

  context 'with a real external service', :testext => true do
    let(:params) { {
      type: 'LEG',
      firstName: 'Joe',
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
      lastNamePrefNld: '',
      countryNameFormat: '001'
    } }
    let(:proxy) { CampusSolutions::PersonName.new(fake: false, user_id: random_id, params: params) }

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
