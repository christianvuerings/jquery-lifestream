require 'spec_helper'

describe CalnetCrosswalk::Proxy do

  context 'mock proxy' do
    let(:fake_proxy) { CalnetCrosswalk::Proxy.new(fake: true) }
    let(:feed) { fake_proxy.get[:feed] }

    it 'returns data with the expected structure' do
      expect(feed[0]['Person']).to be
      expect(feed[0]['Person']['identifiers'][0]['identifierValue']).to eq 'oskibear'
    end
    it 'can be overridden to return errors' do
      fake_proxy.set_response(status: 506, body: '')
      response = fake_proxy.get
      expect(response[:errored]).to eq true
    end

  end
end
