require 'spec_helper'

describe CampusSolutions::Title4 do

  context 'post' do
    let(:params) { {} }
    let(:fake_proxy) { CampusSolutions::Title4.new(fake: true, user_id: random_id, params: params) }

    context 'filtering out fields not on the whitelist' do
      let(:params) { {
        bogus: 1,
        invalid: 2,
        uc_response: 'N'
      } }
      subject { fake_proxy.filter_updateable_params(params) }
      it 'should strip out invalid fields' do
        expect(subject.keys.length).to eq 1
        expect(subject[:bogus]).to be_nil
        expect(subject[:invalid]).to be_nil
        expect(subject[:uc_response]).to be
      end
    end

    context 'converting params to Campus Solutions field names' do
      let(:params) { {
        uc_response: 'Y'
      } }
      subject {
        result = fake_proxy.construct_cs_post(params)
        MultiXml.parse(result)['Title4']
      }
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject['UC_RESPONSE']).to eq 'Y'
        expect(subject['INSTITUTION']).to eq 'UCB01'
      end
    end

    context 'performing a post' do
      let(:params) { {
        uc_response: 'Y'
      } }
      subject {
        fake_proxy.get
      }
      it 'should make a successful post' do
        puts "Subject = #{subject.inspect}"
        expect(subject[:statusCode]).to eq 200
      end
    end
  end

  context 'with a real external service' do # , :testext => true do
    let(:params) { {
      uc_response: 'Y'
    } }
    let(:real_proxy) { CampusSolutions::Title4.new(fake: false, user_id: random_id, params: params) }

    context 'performing a real post' do
      subject {
        real_proxy.get
      }
      it 'should make a successful REAL post' do
        puts "Subject = #{subject.inspect}"
        expect(subject[:statusCode]).to eq 200
      end
    end
  end
end
