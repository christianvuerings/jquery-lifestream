require 'spec_helper'

describe CampusSolutions::Budget do

  context 'mock proxy' do
    let(:oski_uid) { '61889' }
    let(:oski_student_id) { 11667051 }
    let(:fake_proxy) { CampusSolutions::Budget.new(user_id: oski_uid, fake: true) }
    let(:feed) { fake_proxy.get[:feed] }

    it 'returns JSON fixture data by default' do
      p "feed = #{feed.inspect}"
      expect(feed['UC_STDNT_BUD_DTL_RESP']).to be
    end

    it 'can be overridden to return errors' do
      fake_proxy.set_response(status: 506, body: '')
      response = fake_proxy.get
      expect(response[:errored]).to eq true
    end

  end
end
