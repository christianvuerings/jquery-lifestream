require 'spec_helper'

describe CampusSolutions::AddressDelete do

  context 'deleting address' do
    let(:params) { {} }
    let(:proxy) { CampusSolutions::AddressDelete.new(fake: true, user_id: random_id, params: params) }

    context 'converting params to Campus Solutions field names' do
      let(:params) { {
        bogus: 'foo',
        type: 'HOME'
      } }
      subject {
        proxy.construct_cs_post(params)
      }
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject[:query][:TYPE]).to eq 'HOME'
        expect(subject[:query].keys.length).to eq 2
      end
    end

    context 'performing a delete' do
      let(:params) { {
        type: 'HOME'
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
    let(:user_id) { random_id }
    let(:create_params) { {
      addressType: 'HOME',
      address1: '1 Test Lane',
      address2: 'peters road',
      city: 'ventura',
      state: 'CA',
      postal: '93001',
      country: 'USA'
    } }
    before {
      CampusSolutions::Address.new(fake: false, user_id: random_id, params: create_params).get
    }

    let(:proxy) { CampusSolutions::AddressDelete.new(fake: false, user_id: user_id, params: params) }
    subject { proxy.get }

    context 'a successful delete' do
      let(:params) { {
        type: 'HOME'
      } }
      context 'performing a real delete' do
        it_behaves_like 'a proxy that got data successfully'
      end
    end

  end
end
