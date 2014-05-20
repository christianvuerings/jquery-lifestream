require "spec_helper"

describe CacheController do

  let (:user_id) { rand(99999).to_s }
  before do
    session[:user_id] = user_id
    Rails.env.stub(:production?).and_return(true)
  end

  context 'a non-superuser' do
    before do
      User::Auth.stub(:where).and_return([User::Auth.new(uid: user_id, is_superuser: false, active: true)])
    end

    it 'should not allow non-admin users to clear cache' do
      Rails.cache.should_not_receive(:clear)
      get :clear, {:format => 'json'}
      expect(response.status).to eq(403)
      expect(response.body.blank?).to be_true
    end

    it 'should not allow non-admin users to warmup caches' do
      HotPlate.should_not_receive(:request_warmup)
      HotPlate.should_not_receive(:request_warmups_for_all)
      get :warm, {:uid => '1234', :format => 'json'}
      expect(response.status).to eq(403)
      expect(response.body.blank?).to be_true
    end
  end

  context 'a superuser' do

    before do
      User::Auth.stub(:where).and_return([User::Auth.new(uid: user_id, is_superuser: true, active: true)])
    end

    it 'should allow superusers to clear the cache' do
      Rails.cache.should_receive(:clear).once
      get :clear, {:format => 'json'}
      expect(response.status).to eq(200)
      expect(response.body).to be
      expect(response.body['cache_cleared']).to be_true
    end

    it 'should allow superusers users to warmup a single users cache' do
      HotPlate.should_receive(:request_warmup).once.with(1234)
      get :warm, {:uid => '1234', :format => 'json'}
      expect(response.status).to eq(200)
      expect(response.body).to be
      expect(response.body['warmed']).to be_true
    end

    it 'should allow superusers to warmup everyones cache' do
      HotPlate.should_receive(:request_warmups_for_all).once
      get :warm, {:uid => 'all', :format => 'json'}
      expect(response.status).to eq(200)
      expect(response.body).to be
      expect(response.body['warmed']).to be_true
    end
  end

end
