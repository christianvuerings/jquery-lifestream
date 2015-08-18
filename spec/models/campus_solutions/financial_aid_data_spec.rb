require 'spec_helper'

describe CampusSolutions::FinancialAidData do

  context 'mock proxy' do
    let(:fake_proxy) { CampusSolutions::FinancialAidData.new(fake: true) }
    let(:feed) { fake_proxy.get[:feed] }

    it 'returns data with the expected structure' do
      expect(feed['coa']).to be
      expect(feed['status']).to be
    end
    it 'can be overridden to return errors' do
      fake_proxy.set_response(status: 506, body: '')
      response = fake_proxy.get
      expect(response[:errored]).to eq true
    end

  end
end
