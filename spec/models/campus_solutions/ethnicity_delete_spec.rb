require 'spec_helper'

describe CampusSolutions::EthnicityDelete do

  context 'deleting ethnicity' do
    let(:params) { {} }
    let(:proxy) { CampusSolutions::EthnicityDelete.new(fake: true, user_id: random_id, params: params) }

    context 'converting params to Campus Solutions field names' do
      let(:params) { {
        bogus: 'foo',
        regRegion: 'USA',
        ethnicGroupCode: 'ASIANIND'
      } }
      subject {
        proxy.construct_cs_post(params)
      }
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject[:query][:REG_REGION]).to eq 'USA'
        expect(subject[:query][:ETHNIC_GRP_CD]).to eq 'ASIANIND'
        expect(subject[:query].keys.length).to eq 3
      end
    end

    context 'performing a delete' do
      let(:params) { {
        regRegion: 'USA',
        ethnicGroupCode: 'ASIANIND'
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
      regRegion: 'USA',
      ethnicGroupCode: 'ASIANIND',
      isPrimary: 'N',
      isHispanicLatino: 'ab',
      isAmiAln: 'N',
      isAsian: 'N',
      isBlackAfAm: 'N',
      isHawPac: 'N',
      isWhite: 'Y',
      isEthnicityValidated: 'N'
    } }
    before {
      CampusSolutions::EthnicityPost.new(fake: false, user_id: random_id, params: create_params).get
    }

    let(:proxy) { CampusSolutions::EthnicityDelete.new(fake: false, user_id: user_id, params: params) }
    subject { proxy.get }

    context 'a successful delete' do
      let(:params) { {
        regRegion: 'USA',
        ethnicGroupCode: 'ASIANIND'
      } }
      context 'performing a real delete' do
        it_behaves_like 'a proxy that got data successfully'
      end
    end

  end
end
