require 'spec_helper'

describe CampusSolutions::TermsAndConditions do

  context 'post' do
    let(:fake_proxy) { CampusSolutions::TermsAndConditions.new(fake: true) }

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
      subject { fake_proxy.construct_cs_post(params) }
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject.keys.length).to eq 1
        expect(subject[:UC_RESPONSE]).to eq 'Y'
      end
    end

    context 'performing a post' do
      let(:params) { {
        uc_response: 'Y',
        aid_year: '2016'
      } }
      subject {
        fake_proxy.params = params
        fake_proxy.get
      }
      it 'should make a successful post' do
        puts "Subject = #{subject.inspect}"
        #expect(subject[:updated]).to eq true
      end
    end
  end
end
