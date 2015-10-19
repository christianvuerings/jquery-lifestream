require 'spec_helper'

describe HubEdos::WorkExperience do

  context 'mock proxy' do
    let(:proxy) { HubEdos::WorkExperience.new(fake: true, user_id: '61889') }
    subject { proxy.get }

    it_behaves_like 'a proxy that properly observes the profile feature flag'
    it_should_behave_like 'a simple proxy that returns errors'

    it 'returns data with the expected structure' do
      expect(subject[:feed]['workExperiences']).to be
      expect(subject[:feed]['workExperiences'][0]['employer']).to eq('Mat-Su Youth Facility')
      expect(subject[:feed]['workExperiences'].size).to eq(3)
    end
  end

  context 'real proxy', testext: true do
    let(:proxy) { HubEdos::WorkExperience.new(fake: false, user_id: '12351') }
    subject { proxy.get }

    it_behaves_like 'a proxy that properly observes the profile feature flag'

    it 'returns data with the expected structure' do
      expect(subject[:feed]['workExperiences']).to be
    end

  end
end
