require 'spec_helper'

describe SessionsController do
  let(:user_id) { random_id }
  let(:cookie_hash) { {} }

  before(:each) do
    session[:user_id] = user_id
  end

  describe 're-authenticating' do
    context 're-authenticating via view-as' do
      it 'logs the user out when CAS uid does not match original user uid' do
        expect(controller).to receive(:cookies).and_return cookie_hash
        :create_reauth_cookie
        session[:original_user_id] = user_id
        @request.env['omniauth.auth'] = { uid: "some_other_#{user_id}" }
        get :lookup, renew: 'true'
        @response.status.should eq 302
        cookies[:reauthenticated].should be_nil
        session.empty?.should be_true
      end
      it 'will reset session when CAS uid does not match uid in session' do
        expect(controller).to receive(:cookies).and_return cookie_hash
        :create_reauth_cookie
        session[:original_user_id] = user_id
        @request.env['omniauth.auth'] = { 'uid' => user_id }
        get :lookup, renew: 'true'
        @response.status.should eq 302
        reauth_cookie_value = cookie_hash[:reauthenticated]
        reauth_cookie_value.should_not be_nil
        reauth_cookie_value[:value].should be_true
        session.empty?.should be_false
        session[:user_id].should eql user_id
      end
    end
  end

end
