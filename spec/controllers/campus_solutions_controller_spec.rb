require "spec_helper"

describe CampusSolutionsController do

  before(:each) do
    @user_id = rand(99999).to_s
  end

  shared_examples 'an unauthenticated user' do
    it 'returns 401' do
      get feed
      expect(response.status).to eq 401
      expect(response.body.strip).to eq ''
    end
  end

  shared_examples 'a successful feed' do
    it 'has some data' do
      session['user_id'] = user
      get feed
      json = JSON.parse(response.body)
      expect(json['statusCode']).to eq 200
      expect(json['feed'][feed_key]).to be
    end
  end

  context 'country feed' do
    let(:feed) { :country }
    context 'non-authenticated user' do
      it_behaves_like 'an unauthenticated user'
    end

    context 'authenticated user' do
      let(:user) { @user_id }
      let(:feed_key) { 'countries' }
      it_behaves_like 'a successful feed'
    end
  end

  context 'state feed' do
    let(:feed) { :state }
    context 'non-authenticated user' do
      it_behaves_like 'an unauthenticated user'
    end

    context 'authenticated user' do
      let(:user) { @user_id }
      let(:feed_key) { 'states' }
      it_behaves_like 'a successful feed'
    end
  end

  context 'address feed' do
    let(:feed) { :address }
    context 'non-authenticated user' do
      it_behaves_like 'an unauthenticated user'
    end

    context 'authenticated user' do
      let(:user) { @user_id }
      let(:feed_key) { 'addresses' }
      it_behaves_like 'a successful feed'
      it 'has some field mapping info' do
        session['user_id'] = user
        get feed
        json = JSON.parse(response.body)
        expect(json['feed']['fields']['country']['campusSolutionsName']).to eq 'COUNTRY'
      end
    end
  end

  context 'aid years feed' do
    let(:feed) { :aid_years }
    context 'non-authenticated user' do
      it_behaves_like 'an unauthenticated user'
    end

    context 'authenticated user' do
      let(:user) { @user_id }
      let(:feed_key) { 'finaidSummary' }
      it_behaves_like 'a successful feed'
      it 'has some field mapping info' do
        session['user_id'] = user
        get feed
        json = JSON.parse(response.body)
        expect(json['feed']['finaidSummary']['finaidYear'][0]['id']).to eq '2015'
      end
    end
  end

  context 'financial data feed' do
    let(:feed) { :financial_data }
    context 'non-authenticated user' do
      it_behaves_like 'an unauthenticated user'
    end

    context 'authenticated user' do
      let(:user) { @user_id }
      let(:feed_key) { 'coa' }
      it_behaves_like 'a successful feed'
      it 'has some field mapping info' do
        session['user_id'] = user
        get feed, {:aid_year => '2016', :format => 'json'}
        json = JSON.parse(response.body)
        expect(json['feed']['coa']['title']).to eq 'Estimated Cost of Attendance'
      end
    end
  end
  context 'updating an address' do
    it 'should not let an unauthenticated user post' do
      post :address, {format: 'json', uid: '100'}
      expect(response.status).to eq 401
    end

    context 'authenticated user' do
      before do
        session['user_id'] = '1234'
        User::Auth.stub(:where).and_return([User::Auth.new(uid: '1234', is_superuser: true, active: true)])
      end
      it 'should let an authenticated user post' do
        post :update_address,
             {
               bogus_field: 'abc',
               country: 'USA',
               address1: '1 Test Lane',
               address2: 'Suite F',
               address3: 'Box 4',
               address4: 'Pigeonhole Delta',
               city: 'Testville',
               state: 'TN',
               postal: '12345'
             }
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        expect(json['updated']).to eq true
        expect(json['updatedFields']['country']).to eq 'USA'
        expect(json['updatedFields']['address1']).to eq '1 Test Lane'
        expect(json['updatedFields']['address2']).to eq 'Suite F'
        expect(json['updatedFields']['address3']).to eq 'Box 4'
        expect(json['updatedFields']['address4']).to eq 'Pigeonhole Delta'
        expect(json['updatedFields']['city']).to eq 'Testville'
        expect(json['updatedFields']['state']).to eq 'TN'
        expect(json['updatedFields']['postal']).to eq '12345'
        expect(json['updatedFields']['bogus_field']).to be_nil
      end
    end
  end
end
