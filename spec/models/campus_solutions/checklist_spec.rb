require 'spec_helper'

describe CampusSolutions::Checklist do
  shared_examples 'a proxy that gets data' do
    let(:oski_uid) { '61889' }
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that properly observes the profile feature flag'
    it 'returns data with the expected structure' do
      expect(subject[:feed][:personChklstItem][0][:emplid]).to eq '3030000004'
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::Checklist.new(fake: true, user_id: oski_uid) }
    it_should_behave_like 'a proxy that gets data'
  end

  # TODO un-ignore this test when Checklist feed is real in bcsdev
  context 'real proxy', testext: true, ignore: true do
    let(:proxy) { CampusSolutions::Checklist.new(fake: false, user_id: oski_uid) }
    it_should_behave_like 'a proxy that gets data'
  end
end
