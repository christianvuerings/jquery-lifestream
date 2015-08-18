require 'spec_helper'

describe CampusSolutions::Checklist do

  context 'mock proxy' do
    let(:oski_uid) { '61889' }
    let(:oski_student_id) { 11667051 }
    let(:fake_proxy) { CampusSolutions::Checklist.new(user_id: oski_uid, fake: true) }
    let(:feed) { fake_proxy.get[:feed] }

    it 'returns data with the expected structure' do
      expect(feed[:personChklstItem][0][:emplid]).to eq '3030000004'
    end
    it 'can be overridden to return errors' do
      fake_proxy.set_response(status: 506, body: '')
      response = fake_proxy.get
      expect(response[:errored]).to eq true
    end

  end
end
