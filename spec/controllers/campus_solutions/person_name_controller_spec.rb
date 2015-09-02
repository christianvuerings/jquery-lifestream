require 'spec_helper'

describe CampusSolutions::PersonNameController do
  context 'updating name' do
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
               type: 'LEG',
               firstName: 'Joe',
               lastName: 'Test',
               initials: 'JT',
               prefix: 'Mr',
               suffix: '',
               royalPrefix: '',
               royalSuffix: '',
               title: '',
               middleName: '',
               secondLastName: '',
               ac: '',
               preferredFirstName: '',
               partnerLastName: '',
               partnerRoyalPrefix: '',
               lastNamePrefNld: ''
             }
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        expect(json['statusCode']).to eq 200
        expect(json['feed']).to be
        expect(json['feed']['status']).to be
      end
    end
  end
  context 'deleting name' do
    it 'should not let an unauthenticated user delete' do
      delete :delete, {format: 'json', uid: '100'}
      expect(response.status).to eq 401
    end

    context 'authenticated user' do
      before do
        session['user_id'] = '1234'
        User::Auth.stub(:where).and_return([User::Auth.new(uid: '1234', is_superuser: false, active: true)])
      end
      it 'should let an authenticated user delete' do
        delete :delete,
             {
               bogus_field: 'abc',
               type: 'LEG'
             }
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        expect(json['statusCode']).to eq 200
        expect(json['feed']).to be
        expect(json['feed']['status']).to be
      end
    end
  end
end
