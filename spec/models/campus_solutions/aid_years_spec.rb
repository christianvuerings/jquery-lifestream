require 'spec_helper'

describe CampusSolutions::AidYears do

  context 'mock proxy' do
    let(:fake_proxy) { CampusSolutions::AidYears.new(fake: true) }
    let(:feed) { fake_proxy.get[:feed] }

    it 'returns JSON fixture data by default' do
      expect(feed['finaidSummary']['finaidYear']).to be
    end
    it 'can be overridden to return errors' do
      fake_proxy.set_response(status: 506, body: '')
      response = fake_proxy.get
      expect(response[:errored]).to eq true
    end

  end
end
