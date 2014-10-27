require "spec_helper"

describe User::SearchUsersBySid do

  let(:users_found) do
    [
      { 'student_id' => '24680', 'ldap_uid' => '13579' },
    ]
  end

  let(:users_not_found) do
    []
  end

  it "should return valid record for valid sid" do
    CampusOracle::Queries.should_receive(:find_people_by_student_id).with('24680').and_return(users_found)
    model = User::SearchUsersBySid.new({:id => '24680'})
    result = model.search_users_by_sid
    expect(result).to be_an_instance_of Array
    expect(result.count).to eq 1
    expect(result[0]['student_id']).to eq "24680"
    expect(result[0]['ldap_uid']).to eq "13579"
  end

  it "returns no record for invalid sid" do
    CampusOracle::Queries.should_receive(:find_people_by_student_id).with('234567').and_return(users_not_found)
    model = User::SearchUsersBySid.new({:id => '234567'})
    result = model.search_users_by_sid
    expect(result).to be_an_instance_of Array
    expect(result.count).to eq 0
  end

end
