require 'spec_helper'

describe Slate::Checklist do

  it_should_behave_like 'a student data proxy' do
    let(:proxy_class) { Slate::Checklist }
    let(:feed_key) { 'PERSON_CHKLST_ITEM' }
  end

  context 'mock proxy' do
    let(:oski_uid) { '61889' }
    let(:oski_student_id) { 11667051 }
    let(:fake_proxy) { Slate::Checklist.new(user_id: oski_uid, fake: true) }
    let(:feed) { fake_proxy.get[:feed] }

    it 'returns JSON fixture data by default' do
      p "Feed = #{feed.inspect}"
      expect(feed['PERSON_CHKLST_ITEM'][0]['EmplID']).to eq '7777'
      expect(feed['PERSON_CHKLST_ITEM'][0]['NAME']).to eq 'Cheangy, Billy'
    end
    it 'can be overridden to return errors' do
      fake_proxy.set_response(status: 506, body: '')
      response = fake_proxy.get
      expect(response[:errored]).to eq true
    end

  end
end

