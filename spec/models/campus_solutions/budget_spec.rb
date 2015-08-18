require 'spec_helper'

describe CampusSolutions::Budget do

  context 'mock proxy' do
    let(:oski_uid) { '61889' }
    let(:oski_student_id) { 11667051 }
    let(:fake_proxy) { CampusSolutions::Budget.new(user_id: oski_uid, fake: true) }
    let(:feed) { fake_proxy.get[:feed] }

    it 'returns data with the expected structure' do
      expect(feed[:ucStdntBudDtlResp]).to be
    end

    it 'can be overridden to return errors' do
      fake_proxy.set_response(status: 506, body: '')
      response = fake_proxy.get
      expect(response[:errored]).to eq true
    end

  end
end
