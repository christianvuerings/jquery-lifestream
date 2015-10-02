require 'spec_helper'

describe CampusSolutions::PendingMessages do
  let(:user_id) { '12348' }
  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that properly observes the profile feature flag'
    it_behaves_like 'a proxy that got data successfully'
    it 'returns data with the expected structure' do
      expect(subject[:feed][:commMessagePendingResponse][0][:emplid]).to be
      expect(subject[:feed][:commMessagePendingResponse][0][:descr]).to be
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::PendingMessages.new(fake: true, user_id: user_id) }
    subject { proxy.get }
    it_should_behave_like 'a proxy that gets data'
    it 'returns specific mock data' do
      p "subj=#{subject}"
      expect(subject[:feed][:commMessagePendingResponse][0][:emplid]).to eq '24188949'
      expect(subject[:feed][:commMessagePendingResponse][0][:descr]).to eq 'Campus Provided Software'
    end
  end

  context 'real proxy', testext: true do
    let(:proxy) { CampusSolutions::PendingMessages.new(fake: false, user_id: user_id) }
    it_should_behave_like 'a proxy that gets data'
  end
end
