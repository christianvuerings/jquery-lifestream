require "spec_helper"

describe UserApiController do

  before do
    @user_id = rand(999999).to_s
  end

  it "should not have a logged-in status" do
    get :mystatus
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response["is_logged_in"].should == false
    json_response["uid"].should be_nil
    json_response["features"].should_not be_nil
  end

  it "should show status for a logged-in user" do
    session[:user_id] = "238382"
    get :mystatus
    json_response = JSON.parse(response.body)
    json_response["is_logged_in"].should == true
    json_response["uid"].should == "238382"
    json_response["preferred_name"].should_not be_nil
    json_response["features"].should_not be_nil
    visit = User::Visit.where(:uid=>session[:user_id])[0]
    visit.last_visit_at.should_not be_nil
  end

  it "should record first login for a new user" do
    CampusOracle::Queries.stub(:get_person_attributes) do |uid|
      {
        'person_name' => "Joe Test",
        :roles => {
          :student => true,
          :faculty => false,
          :staff => false
        }
      }
    end
    session[:user_id] = @user_id
    get :mystatus
    json_response = JSON.parse(response.body)
    json_response["first_login_at"].should == nil
    get :record_first_login
    response.status.should == 204
    get :mystatus
    json_response = JSON.parse(response.body)
    json_response["first_login_at"].should_not be_nil
  end

  let(:users_found) do
    [
      { 'student_id' => '24680', 'ldap_uid' => '13579' },
    ]
  end

  let(:users_not_found) do
    []
  end

  it "returns valid records for valid uid or sid" do
    User::SearchUsers.should_receive(:search_users).with('13579').and_return(users_found)
    get :search_users, id: "13579"
    expect(response.status).to eq(200)
    json_response = JSON.parse(response.body)
    expect(json_response['users']).to be_an_instance_of Array
    expect(json_response['users'].count).to eq 1
    expect(json_response['users'][0]['student_id']).to eq "24680"
    expect(json_response['users'][0]['ldap_uid']).to eq "13579"
    json_response['users'].each do |user|
      expect(user).to be_an_instance_of Hash
    end
  end

  it "returns no record for invalid uid and sid" do
    User::SearchUsers.should_receive(:search_users).with('12345').and_return(users_not_found)
    get :search_users, id: "12345"
    expect(response.status).to eq(200)
    json_response = JSON.parse(response.body)
    expect(json_response['users']).to be_an_instance_of Array
    expect(json_response['users'].count).to eq 0
  end

end
