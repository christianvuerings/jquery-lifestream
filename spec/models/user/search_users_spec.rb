describe User::SearchUsers do

  let(:users_found) do
    [
      { 'student_id' => '24680', 'ldap_uid' => '13579' },
    ]
  end

  let(:users_not_found) do
    []
  end

  it "should return valid record for valid uid" do
    CampusOracle::Queries.should_receive(:get_basic_people_attributes).with(['13579']).and_return(users_found)
    CampusOracle::Queries.should_receive(:find_people_by_student_id).with('13579').and_return(users_not_found)
    model = User::SearchUsers.new({:id => '13579'})
    result = model.search_users
    expect(result).to be_an_instance_of Array
    expect(result.count).to eq 1
    expect(result[0]['student_id']).to eq "24680"
    expect(result[0]['ldap_uid']).to eq "13579"
  end

  it "should return valid record for valid sid" do
    CampusOracle::Queries.should_receive(:find_people_by_student_id).with('24680').and_return(users_found)
    CampusOracle::Queries.should_receive(:get_basic_people_attributes).with(['24680']).and_return(users_not_found)
    model = User::SearchUsers.new({:id => '24680'})
    result = model.search_users
    expect(result).to be_an_instance_of Array
    expect(result).to be_an_instance_of Array
    expect(result.count).to eq 1
    expect(result[0]['student_id']).to eq "24680"
    expect(result[0]['ldap_uid']).to eq "13579"
  end

  it "returns no record for invalid id" do
    CampusOracle::Queries.should_receive(:find_people_by_student_id).with('12345').and_return(users_not_found)
    CampusOracle::Queries.should_receive(:get_basic_people_attributes).with(['12345']).and_return(users_not_found)
    model = User::SearchUsers.new({:id => '12345'})
    result = model.search_users
    expect(result).to be_an_instance_of Array
    expect(result.count).to eq 0
  end

end
