require "spec_helper"

describe SessionsController do
  let(:user_id) { random_id }
  before do
    session[:user_id] = user_id
  end

  context 'when re-authenticating via view-as' do
    it 'CAS uid does not match original user uid' do
      allow(controller).to receive(:cookies).and_return({reauthenticated: nil})
      :create_reauth_cookie
      session[:original_user_id] = user_id
      session["arbitrary"] = user_id

      @request.env["omniauth.auth"] = { uid: "some_other_#{user_id}" }
      get :lookup, renew: "true"

      @response.status.should eq(302)
      cookies[:reauthenticated].should be_nil
      session.empty?.should be_true
    end
  end

end