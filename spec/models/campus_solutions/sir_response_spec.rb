require 'spec_helper'

describe CampusSolutions::SirResponse do

  context 'post' do
    let(:params) { {} }
    let(:proxy) { CampusSolutions::SirResponse.new(fake: true, user_id: random_id, params: params) }

    context 'filtering out fields not on the whitelist' do
      let(:params) { {
        bogus: 1,
        invalid: 2,
        studentCarNbr: '1234'
      } }
      subject { proxy.filter_updateable_params(params) }
      it 'should strip out invalid fields' do
        expect(subject.keys.length).to eq 7
        expect(subject[:bogus]).to be_nil
        expect(subject[:invalid]).to be_nil
        expect(subject[:studentCarNbr]).to eq '1234'
      end
    end

    context 'converting params to Campus Solutions field names' do
      let(:params) { {
        studentCarNbr: '1234'
      } }
      subject {
        result = proxy.construct_cs_post(params)
        MultiXml.parse(result)['UC_AD_SIR']
      }
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject['STDNT_CAR_NBR']).to eq '1234'
      end
    end

    context 'performing a post' do
      let(:params) { {
        studentCarNbr: '1234'
      } }
      subject {
        proxy.get
      }
      it_should_behave_like 'a simple proxy that returns errors'
      it_behaves_like 'a proxy that properly observes the profile feature flag'
      it_behaves_like 'a proxy that got data successfully'
    end
  end

  # ignored until errors in real post are explained
  context 'with a real external service', ignore: true, testext: true do
    let(:proxy) { CampusSolutions::SirResponse.new(fake: false, user_id: random_id, params: params) }
    subject { proxy.get }

    context 'a successful post' do
      let(:params) { {
        studentCarNbr: '1234'
      } }
      context 'performing a real post' do
        it_behaves_like 'a proxy that got data successfully'
      end
    end

    context 'an invalid post' do
      let(:params) { {
        studentCarNbr: '1234'
      } }
      context 'performing a real but invalid post' do
        it_should_behave_like 'a simple proxy that returns errors'
        it_should_behave_like 'a proxy that responds to user error gracefully'
      end
    end
  end
end
