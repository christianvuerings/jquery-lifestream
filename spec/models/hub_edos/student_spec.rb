require 'spec_helper'

describe HubEdos::Student do

  context 'mock proxy' do
    let(:fake_proxy) { HubEdos::Student.new(fake: true) }
    let(:feed) { fake_proxy.get[:feed] }

    it 'returns data with the expected structure' do
      expect(feed['student']).to be
      expect(feed['student']['identifiers'][0]['id']).to be
      expect(feed['student']['academicCareers'][0]['career']).to be
    end
    it 'can be overridden to return errors' do
      fake_proxy.set_response(status: 506, body: '')
      response = fake_proxy.get
      expect(response[:errored]).to eq true
    end

  end
end
