require 'spec_helper'

describe CampusSolutions::HigherOneUrl do

  let(:user_id) { '12349' }

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that properly observes the profile feature flag'
    it_behaves_like 'a proxy that got data successfully'
    it 'returns data with the expected structure' do
      expect(subject[:feed][:root][:higherOneUrl][:url]).to be
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::HigherOneUrl.new(fake: true, user_id: user_id) }
    subject { proxy.get }
    it_should_behave_like 'a proxy that gets data'
    it 'should get specific mock data' do
      expect(subject[:feed][:root][:higherOneUrl][:url].strip).to eq 'https://commerce.cashnet.com/UCBpaytest?eusername=8062064084e9a8dff7a181266a3ed11e28b80eb30ab4fd84b9bc4de92394d884'
    end
  end

  context 'real proxy', testext: true do
    let(:proxy) { CampusSolutions::HigherOneUrl.new(fake: false, user_id: user_id) }
    it_should_behave_like 'a proxy that gets data'
  end

end
