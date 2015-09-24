require 'spec_helper'

describe HubEdos::Student do

  context 'mock proxy' do
    let(:proxy) { HubEdos::Student.new(fake: true) }
    subject { proxy.get }

    it_behaves_like 'a proxy that properly observes the profile feature flag'
    it_should_behave_like 'a simple proxy that returns errors'

    it 'returns data with the expected structure' do
      expect(subject[:feed]['student']).to be
      expect(subject[:feed]['student']['identifiers'][0]['id']).to be
      expect(subject[:feed]['student']['studentPlans'][0]['academicPlan']['academicProgram']['academicCareer']['code']).to eq 'UGRD'
    end
  end

  context 'real proxy', testext: true, ignore: true do
    let(:proxy) { HubEdos::Student.new(fake: false, user_id: '61889') }
    subject { proxy.get }

    it_behaves_like 'a proxy that properly observes the profile feature flag'
    it_should_behave_like 'a simple proxy that returns errors'

    it 'returns data with the expected structure' do
      expect(subject[:feed]['student']).to be
      expect(subject[:feed]['student']['identifiers'][0]['id']).to be
    end

  end
end
