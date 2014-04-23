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

  context "reauthentication" do
    before(:each) {
      ApplicationController.any_instance.stub(:is_admin?).and_return(true)
      Settings.features.stub(:reauthentication).and_return(true)
      session[:user_id] = @user_id
    }
    context "for admin users acting as another user" do
      it "should redirect to /auth/cas?renew=true the first time they try to act as" do
        ApplicationController.any_instance.stub(:acting_as?).and_return(true)
        controller.stub(:cookies).and_return({:reauthenticated => nil})
        get :index
        expect(response).to redirect_to('/auth/cas?renew=true')
      end

    end

  end
end
