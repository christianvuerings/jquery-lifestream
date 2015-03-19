require "spec_helper"

describe SearchUsersController do
  before do
    session['user_id'] = "1234"
    User::Auth.stub(:where).and_return([User::Auth.new(uid: "1234", is_superuser: true, active: true)])
  end

  let(:users_found) do
    [
      { 'student_id' => '24680', 'ldap_uid' => '13579' },
    ]
  end

  let(:users_not_found) do
    []
  end

  describe "#search_users" do

    it "returns valid records for valid uid or sid" do
      stub_model = double
      User::SearchUsers.should_receive(:new).with({id: '13579'}).and_return(stub_model)
      stub_model.should_receive(:search_users).and_return(users_found)

      get :search_users, id: '13579'
      expect(response.status).to eq(200)
      json_response = JSON.parse(response.body)
      expect(json_response['users']).to be_an_instance_of Array
      expect(json_response['users'].count).to eq 1
      expect(json_response['users'][0]['student_id']).to eq '24680'
      expect(json_response['users'][0]['ldap_uid']).to eq '13579'
      json_response['users'].each do |user|
        expect(user).to be_an_instance_of Hash
      end
    end

    it "returns no record for invalid uid and sid" do
      stub_model = double
      User::SearchUsers.should_receive(:new).with({id: '12345'}).and_return(stub_model)
      stub_model.should_receive(:search_users).and_return(users_not_found)

      get :search_users, id: '12345'
      expect(response.status).to eq(200)
      json_response = JSON.parse(response.body)
      expect(json_response['users']).to be_an_instance_of Array
      expect(json_response['users'].count).to eq 0
    end

  end

  describe "#search_users_by_uid" do

    it "returns valid records for valid uid" do
      stub_model = double
      User::SearchUsersByUid.should_receive(:new).with({id: '13579'}).and_return(stub_model)
      stub_model.should_receive(:search_users_by_uid).and_return(users_found)

      get :search_users_by_uid, id: '13579'
      expect(response.status).to eq(200)
      json_response = JSON.parse(response.body)
      expect(json_response['users']).to be_an_instance_of Array
      expect(json_response['users'].count).to eq 1
      expect(json_response['users'][0]['student_id']).to eq '24680'
      expect(json_response['users'][0]['ldap_uid']).to eq '13579'
      json_response['users'].each do |user|
        expect(user).to be_an_instance_of Hash
      end
    end

    it "returns no record for invalid uid" do
      stub_model = double
      User::SearchUsersByUid.should_receive(:new).with({id: '12345'}).and_return(stub_model)
      stub_model.should_receive(:search_users_by_uid).and_return(users_not_found)

      get :search_users_by_uid, id: '12345'
      expect(response.status).to eq(200)
      json_response = JSON.parse(response.body)
      expect(json_response['users']).to be_an_instance_of Array
      expect(json_response['users'].count).to eq 0
    end

  end

end
