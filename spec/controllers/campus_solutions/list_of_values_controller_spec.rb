require 'spec_helper'

describe CampusSolutions::ListOfValuesController do
  context 'list of values feed' do
    it 'should not let an unauthenticated user post' do
      get :get, {fieldName: 'COUNTRY_NM_FORMAT', recordName: 'NAME_FORMAT_TBL'}
      expect(response.status).to eq 401
    end

    context 'authenticated user' do
      before do
        session['user_id'] = '1234'
        User::Auth.stub(:where).and_return([User::Auth.new(uid: '1234', is_superuser: false, active: true)])
      end
      it 'should let an authenticated user get' do
        get :get, {fieldName: 'COUNTRY_NM_FORMAT', recordName: 'NAME_FORMAT_TBL'}
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        expect(json['statusCode']).to eq 200
        expect(json['feed']).to be
        expect(json['feed']['values']).to be
      end
    end
  end
end

