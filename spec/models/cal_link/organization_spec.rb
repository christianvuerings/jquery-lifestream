require 'spec_helper'

describe CalLink::Organization do

  subject { CalLink::Organization.new(org_id: '65797', fake: false).get_organization }

  it 'should get the fake org feed from CalLink' do
    client = CalLink::Organization.new(org_id: '65797', fake: true)
    data = client.get_organization
    expect(data[:statusCode]).to eq 200
    expect(data[:body]['items'][0]['name']).to eq 'Bears Ice Hockey'
  end

  it 'should get the real org feed from CalLink', :testext => true do
    client = CalLink::Organization.new(org_id: '65797', fake: false)
    data = client.get_organization
    expect(data[:statusCode]).to eq 200
    expect(data[:body]).to be_present
  end

  it_behaves_like 'a polite HTTP client'
  it_behaves_like 'a proxy logging errors'

end
