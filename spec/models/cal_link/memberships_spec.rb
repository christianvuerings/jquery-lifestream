require 'spec_helper'

describe CalLink::Memberships do
  let! (:uid) { '300846' }

  it 'should get the fake membership feed from CalLink' do
    client = CalLink::Memberships.new(user_id: uid, fake: true)
    data = client.get_memberships
    expect(data[:statusCode]).to eq 200
    expect(data[:body]['items']).to be_present
  end

  it 'should get the real membership feed from CalLink', :testext => true do
    client = CalLink::Memberships.new(user_id: uid, fake: false)
    data = client.get_memberships
    expect(data[:statusCode]).to eq 200
    expect(data[:body]).to be_present
  end

  it_should_behave_like 'a proxy logging errors' do
    subject { CalLink::Memberships.new(user_id: uid, fake: false).get_memberships }
  end

end
