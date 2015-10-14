require 'spec_helper'

describe CampusSolutions::Phone do

  let(:user_id) { '12345' }

  context 'post' do
    let(:params) { {} }
    let(:proxy) { CampusSolutions::Phone.new(fake: true, user_id: user_id, params: params) }

    context 'filtering out fields not on the whitelist' do
      let(:params) { {
        bogus: 1,
        invalid: 2,
        phone: '1234'
      } }
      subject { proxy.filter_updateable_params(params) }
      it 'should strip out invalid fields' do
        expect(subject.keys.length).to eq 5
        expect(subject[:bogus]).to be_nil
        expect(subject[:invalid]).to be_nil
        expect(subject[:phone]).to eq '1234'
        expect(subject[:extension]).to eq ''
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
      it_behaves_like 'a proxy that properly observes the profile feature flag'
      it_behaves_like 'a proxy that got data successfully'
    end
  end

  context 'with a real external service', :testext => true do
    let(:params) { {
      type: 'CELL',
      phone: '9949919892',
      countryCode: '91',
      extension: '23',
      isPreferred: 'Y'
    } }
    let(:proxy) { CampusSolutions::Phone.new(fake: false, user_id: user_id, params: params) }

    context 'performing a real post' do
      subject {
        proxy.get
      }
      it_should_behave_like 'a simple proxy that returns errors'
      it_behaves_like 'a proxy that got data successfully'
    end
  end
end
