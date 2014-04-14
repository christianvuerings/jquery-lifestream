require "spec_helper"

describe BootstrapController do

  before(:each){ @user_id = rand(99999).to_s }

  context "for unauthorized users" do
    it "should not make a warmup request" do
      LiveUpdatesWarmer.should_not_receive(:warmup_request).with(session[:user_id])
      get :index
    end
  end

  context "for authorized users" do
    before(:each){ session[:user_id] = @user_id }

    it "should make a warmup request" do
      LiveUpdatesWarmer.should_receive(:warmup_request).with(session[:user_id]).once
      get :index
    end
  end

  context "for admin users acting as another user" do
    before {
      ApplicationController.any_instance.stub(:is_admin?).and_return(true)
      ApplicationController.any_instance.stub(:acting_as?).and_return(true)
      Settings.features.stub(:reauthentication).and_return(true)
    }
    it "should redirect to /auth/cas?renew=true the first time they try to act as" do
      session[:user_id] = @user_id
      request.cookies[:reauthenticated] = nil
      get :index
      expect(response).to redirect_to('/auth/cas?renew=true')
    end

  end
end
