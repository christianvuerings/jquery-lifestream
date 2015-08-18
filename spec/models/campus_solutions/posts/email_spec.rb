require 'spec_helper'

describe CampusSolutions::Email do

  context 'post' do
    let(:params) { {} }
    let(:fake_proxy) { CampusSolutions::Email.new(fake: true, user_id: random_id, params: params) }

    context 'filtering out fields not on the whitelist' do
      let(:params) { {
        bogus: 1,
        invalid: 2,
        email: 'foo@foo.com'
      } }
      subject { fake_proxy.filter_updateable_params(params) }
      it 'should strip out invalid fields' do
        expect(subject.keys.length).to eq 1
        expect(subject[:bogus]).to be_nil
        expect(subject[:invalid]).to be_nil
        expect(subject[:email]).to eq 'foo@foo.com'
      end
    end

    context 'converting params to Campus Solutions field names' do
      let(:params) { {
        type: 'CAMP',
        email: 'foo@foo.com'
      } }
      subject {
        result = fake_proxy.construct_cs_post(params)
        MultiXml.parse(result)['EMAIL_ADDRESS']
      }
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject['E_ADDR_TYPE']).to eq 'CAMP'
        expect(subject['EMAIL_ADDR']).to eq 'foo@foo.com'
      end
    end

    context 'performing a post' do
      let(:params) { {
        type: 'CAMP',
        email: 'foo@foo.com',
        isPreferred: 'N'
      } }
      subject {
        fake_proxy.get
      }
      it 'should make a successful post' do
        expect(subject[:statusCode]).to eq 200
        expect(subject[:feed][:status]).to be
      end
    end
  end

  context 'with a real external service', :testext => true do
    let(:params) { {
      type: 'CAMP',
      email: 'foo@foo.com',
      isPreferred: 'N'
    } }
    let(:real_proxy) { CampusSolutions::Email.new(fake: false, user_id: random_id, params: params) }

    context 'performing a real post' do
      subject {
        real_proxy.get
      }
      it 'should make a successful REAL post' do
        expect(subject[:statusCode]).to eq 200
        expect(subject[:feed][:status]).to be
      end
    end
  end
end
