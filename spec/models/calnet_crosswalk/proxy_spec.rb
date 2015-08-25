require 'spec_helper'

describe CalnetCrosswalk::Proxy do

  shared_examples 'a proxy that returns data' do
    it 'returns data with the expected structure' do
      expect(feed[0]['Person']).to be
      expect(feed[0]['Person']['identifiers'][0]['identifierValue']).to be
    end
  end

  context 'mock proxy' do
    let(:proxy) { CalnetCrosswalk::Proxy.new(user_id: '61889', fake: true) }
    let(:feed) { proxy.get[:feed] }
    it_behaves_like 'a proxy that returns data'
    it 'can be overridden to return errors' do
      proxy.set_response(status: 506, body: '')
      response = proxy.get
      expect(response[:errored]).to eq true
    end
  end

  context 'real proxy', testext: true do
    let(:proxy) { CalnetCrosswalk::Proxy.new(user_id: '1', fake: false) }
    let(:feed) { proxy.get[:feed] }
    it_behaves_like 'a proxy that returns data'
  end

end
