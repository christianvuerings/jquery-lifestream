require 'spec_helper'

describe CampusSolutions::PhoneDelete do

  context 'deleting phone' do
    let(:params) { {} }
    let(:proxy) { CampusSolutions::PhoneDelete.new(fake: true, user_id: random_id, params: params) }

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
      it 'should make a successful delete' do
        expect(subject[:statusCode]).to eq 200
        expect(subject[:feed][:status]).to be
      end
    end
  end

  context 'with a real external service', testext: true do
    let(:user_id) { random_id }
    let(:create_home_params) { {
      type: 'HOME',
      phone: '9949919892',
      countryCode: '91',
      extension: '23',
      isPreferred: 'Y'
    } }
    let(:create_cell_params) { {
      type: 'CELL',
      phone: '9949919892',
      countryCode: '91',
      extension: '23',
      isPreferred: 'N'
    } }
    before {
      CampusSolutions::Phone.new(fake: false, user_id: random_id, params: create_home_params).get
      CampusSolutions::Phone.new(fake: false, user_id: random_id, params: create_cell_params).get
    }

    let(:proxy) { CampusSolutions::PhoneDelete.new(fake: false, user_id: user_id, params: params) }
    subject { proxy.get }

    context 'a successful delete' do
      let(:params) { {
        type: 'CELL'
      } }
      context 'performing a real delete' do
        it 'should make a successful REAL delete' do
          expect(subject[:statusCode]).to eq 200
          expect(subject[:feed][:status]).to be
        end
      end
    end

  end
end
