require 'spec_helper'

describe AddressController do

  context 'address feed', :ignore => true do
    let(:feed) { :get }
    it_behaves_like 'an unauthenticated user'

    context 'authenticated user' do
      let(:user) { random_id }
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

  context 'updating an address', :ignore => true do
    it 'should not let an unauthenticated user post' do
      post :post, {format: 'json', uid: '100'}
      expect(response.status).to eq 401
    end

    context 'authenticated user' do
      before do
        session['user_id'] = '1234'
        User::Auth.stub(:where).and_return([User::Auth.new(uid: '1234', is_superuser: false, active: true)])
      end
      it 'should let an authenticated user post' do
        post :post,
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
