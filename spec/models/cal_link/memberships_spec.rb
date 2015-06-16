require 'spec_helper'

describe CalLink::Memberships do
  let! (:uid) { '300846' }

  subject { CalLink::Memberships.new(user_id: uid, fake: false).get_memberships }

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

  it_behaves_like 'a proxy logging errors'
  it_behaves_like 'a polite HTTP client'

end
