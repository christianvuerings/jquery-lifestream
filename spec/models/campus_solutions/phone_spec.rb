require 'spec_helper'

describe CampusSolutions::Phone do

  context 'post' do
    let(:params) { {} }
    let(:proxy) { CampusSolutions::Phone.new(fake: true, user_id: random_id, params: params) }

    context 'filtering out fields not on the whitelist' do
      let(:params) { {
        bogus: 1,
        invalid: 2,
        phone: '1234'
      } }
      subject { proxy.filter_updateable_params(params) }
      it 'should strip out invalid fields' do
        expect(subject.keys.length).to eq 1
        expect(subject[:bogus]).to be_nil
        expect(subject[:invalid]).to be_nil
        expect(subject[:phone]).to eq '1234'
      end
    end

    context 'converting params to Campus Solutions field names' do
      let(:params) { {
        type: 'CELL',
        phone: '1234'
      } }
      subject {
        result = proxy.construct_cs_post(params)
        MultiXml.parse(result)['PERSON_PHONE']
      }
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject['PHONE_TYPE']).to eq 'CELL'
        expect(subject['PHONE']).to eq '1234'
      end
    end

    context 'performing a post' do
      let(:params) { {
        type: 'CELL',
        phone: '1234'
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
      type: 'CELL',
      phone: '9949919892',
      countryCode: '91',
      extension: '23',
      isPreferred: 'N'
    } }
    let(:proxy) { CampusSolutions::Phone.new(fake: false, user_id: random_id, params: params) }

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
