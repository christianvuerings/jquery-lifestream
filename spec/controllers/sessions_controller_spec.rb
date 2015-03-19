require 'spec_helper'

describe SessionsController do
  let(:user_id) { random_id }
  let(:cookie_hash) { {} }
  let(:response_body) { nil }

  before(:each) do
    @request.env['omniauth.auth'] = { 'uid' => user_id }
    cookie_hash = {}
    :logout
  end

  describe '#lookup' do
    it 'logs the user out when CAS uid does not match original user uid' do
      expect(controller).to receive(:cookies).and_return cookie_hash
      :create_reauth_cookie
      different_user_id = "some_other_#{user_id}"
      session['original_user_id'] = different_user_id
      session['user_id'] = different_user_id

      get :lookup, renew: 'true'

      @response.status.should eq 302
      cookie_hash[:reauthenticated].should be_nil
      session.empty?.should be_truthy
      cookie_hash.empty?.should be_truthy
    end
    it 'will create reauth cookie if original user_id not found in session' do
      expect(controller).to receive(:cookies).and_return cookie_hash
      session['user_id'] = user_id

      get :lookup, renew: 'true'

      cookie_hash[:reauthenticated].should_not be_nil
      reauth_cookie = cookie_hash[:reauthenticated]
      reauth_cookie[:value].should be_truthy
      (reauth_cookie[:expires] > Date.today).should be_truthy
      session.empty?.should be_falsey
      session['user_id'].should eql user_id
    end
    it 'will reset session when CAS uid does not match uid in session' do
      expect(controller).to receive(:cookies).and_return cookie_hash
      :create_reauth_cookie
      session['original_user_id'] = user_id
      session['user_id'] = user_id

      get :lookup, renew: 'true'

      reauth_cookie = cookie_hash[:reauthenticated]
      reauth_cookie.should_not be_nil
      reauth_cookie[:value].should be_truthy
      (reauth_cookie[:expires] > Date.today).should be_truthy
      session.empty?.should be_falsey
      session['user_id'].should eql user_id
    end
    it 'will redirect to CAS logout, despite LTI user session, when CAS user_id is an unexpected value' do
      expect(controller).to receive(:cookies).and_return cookie_hash
      session['lti_authenticated_only'] = true
      session['user_id'] = "some_other_#{user_id}"

      # No 'renew' param
      get :lookup

      session.empty?.should be_truthy
      cookie_hash.empty?.should be_truthy
    end
  end

  describe '#reauth_admin' do
    it 'will redirect to designated reauth path' do
      # The after hook below will make the appropriate assertions
      get :reauth_admin
    end
  end

  after(:each) do
    @response.status.should eq 302
    @response.body.should_not be_nil
    @response.body.should include 'redirected'
  end

end
