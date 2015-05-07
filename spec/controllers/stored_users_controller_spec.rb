require 'spec_helper'

describe StoredUsersController do

  before do
    session['user_id'] = '1234'
    User::Auth.stub(:where).and_return([User::Auth.new(uid: '1234', is_superuser: true, active: true)])
  end

  let(:error_response) do
    {
      'success' => false,
      'message' => 'Please provide a numeric UID.'
    }
  end

  let(:success_response) do
      {
        'success' => true
      }
  end

  let(:users_found) do
    {
      :saved => [
        {
          :ldap_uid => '1'
        }
      ],
      :recent => [
        {
          :ldap_uid => '2'
        }
      ]
    }
  end

  describe '#get' do

    it 'should return stored users' do
      User::StoredUsers.should_receive(:get).with('1234').and_return(users_found)

      get :get
      expect(response.status).to eq(200)
      json_response = JSON.parse(response.body)
      expect(json_response['users']).to be_an_instance_of Hash
      expect(json_response['users']['saved']).to be_an_instance_of Array
      expect(json_response['users']['recent']).to be_an_instance_of Array
      expect(json_response['users']['saved'][0]['ldap_uid']).to eq '1'
      expect(json_response['users']['recent'][0]['ldap_uid']).to eq '2'
    end

  end

  describe '#store_saved_uid' do

    it 'should return error_response on invalid uid' do
      post :store_saved_uid, { format: 'json', uid: 'not_numeric' }
      expect(response.status).to eq(400)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to eq false
      expect(json_response['message']).to eq 'Please provide a numeric UID.'
    end

    it 'should return success_response on valid uid' do
      User::StoredUsers.should_receive(:store_saved_uid).with('1234', '100').and_return(success_response)

      post :store_saved_uid, { format: 'json', uid: '100' }
      expect(response.status).to eq(200)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to eq true
    end

  end

  describe '#delete_saved_uid' do

    it 'should return error_response on invalid uid' do
      post :delete_saved_uid, { format: 'json', uid: 'not_numeric' }
      expect(response.status).to eq(400)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to eq false
      expect(json_response['message']).to eq 'Please provide a numeric UID.'
    end

    it 'should return success_response on valid uid' do
      User::StoredUsers.should_receive(:delete_saved_uid).with('1234', '100').and_return(success_response)

      post :delete_saved_uid, { format: 'json', uid: '100' }
      expect(response.status).to eq(200)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to eq true
    end

  end

  describe '#delete_all_recent' do
    it 'should return success_response' do
      User::StoredUsers.should_receive(:delete_all_recent).with('1234').and_return(success_response)

      post :delete_all_recent, { format: 'json' }
      expect(response.status).to eq(200)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to eq true
    end
  end

  describe '#delete_all_saved' do
    it 'should return success_response' do
      User::StoredUsers.should_receive(:delete_all_saved).with('1234').and_return(success_response)

      post :delete_all_saved, { format: 'json' }
      expect(response.status).to eq(200)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to eq true
    end
  end

end
