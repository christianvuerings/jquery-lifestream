require 'spec_helper'

describe CampusSolutions::EthnicityController do

  let(:user_id) { '12346' }

  context 'updating ethnicity' do
    it 'should not let an unauthenticated user post' do
      post :post, {format: 'json', uid: '100'}
      expect(response.status).to eq 401
    end

    context 'authenticated user' do
      before do
        session['user_id'] = user_id
        User::Auth.stub(:where).and_return([User::Auth.new(uid: user_id, is_superuser: false, active: true)])
      end
      it 'should let an authenticated user post' do
        post :post,
             {
               bogus_field: 'abc',
               regRegion: 'USA',
               ethnicGroupCode: 'ASIANIND',
               isPrimary: 'N',
               isHispanicLatino: 'ab',
               isAmiAln: 'N',
               isAsian: 'N',
               isBlackAfAm: 'N',
               isHawPac: 'N',
               isWhite: 'Y',
               isEthnicityValidated: 'N'
             }
        expect(response.status).to eq 200
        json = JSON.parse(response.body)
        expect(json['statusCode']).to eq 200
        expect(json['feed']).to be
        expect(json['feed']['status']).to be
      end
    end
  end
  context 'deleting ethnicity' do
    it 'should not let an unauthenticated user delete' do
      delete :delete, {format: 'json', uid: '100'}
      expect(response.status).to eq 401
    end

    context 'authenticated user' do
      before do
        session['user_id'] = user_id
        User::Auth.stub(:where).and_return([User::Auth.new(uid: user_id, is_superuser: false, active: true)])
      end
      it 'should let an authenticated user delete' do
        delete :delete,
               {
                 bogus_field: 'abc',
                 regRegion: 'USA',
                 ethnicGroupCode: 'ASIANIND'
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
