require 'spec_helper'

describe CampusSolutions::WorkExperience do

  context 'post' do
    let(:params) { {} }
    let(:proxy) { CampusSolutions::WorkExperience.new(fake: true, user_id: random_id, params: params) }

    context 'filtering out fields not on the whitelist' do
      let(:params) { {
        bogus: 1,
        invalid: 2,
        addressType: 'HOME'
      } }
      subject { proxy.filter_updateable_params(params) }
      it 'should strip out invalid fields' do
        expect(subject.keys.length).to eq 1
        expect(subject[:bogus]).to be_nil
        expect(subject[:invalid]).to be_nil
        expect(subject[:addressType]).to eq 'HOME'
      end
    end

    context 'converting params to Campus Solutions field names' do
      let(:params) { {
        addressType: 'HOME'
      } }
      subject {
        result = proxy.construct_cs_post(params)
        MultiXml.parse(result)['Prior_Work_Exp']
      }
      it 'should convert the CalCentral params to Campus Solutions params without exploding on bogus fields' do
        expect(subject['ADDRESS_TYPE']).to eq 'HOME'
      end
    end

    context 'performing a post' do
      let(:params) { {
        addressType: 'HOME',
        isRetired: 'N'
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
      extOrganizationId: '9000000008',
      isRetired: 'N',
      workExpAddrType: 'ADDR',
      country: 'USA',
      addressType: 'HOME',
      city: 'ventura',
      state: 'CA',
      phoneType: '',
      phone: '1234',
      startDt: '2012-08-11',
      endDt: '2015-08-11',
      retirementDt: '',
      titleLong: 'Test Title',
      employFrac: '10',
      hoursPerWeek: '4',
      endingPayRate: '10000',
      currencyCd: 'USD',
      payFrequency: 'M'
    } }
    let(:proxy) { CampusSolutions::WorkExperience.new(fake: false, user_id: random_id, params: params) }

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
