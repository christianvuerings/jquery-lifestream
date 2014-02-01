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

end
