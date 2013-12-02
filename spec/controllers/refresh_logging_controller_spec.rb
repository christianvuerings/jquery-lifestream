require "spec_helper"

describe RefreshLoggingController do
  before(:each) do
    @user_id = rand(99999).to_s
  end

  it "should not allow non-admin users to do anything to the logging level" do
    session[:user_id] = @user_id
    Rails.env.stub(:production?).and_return(true)
    CalcentralLogging.should_not_receive(:refresh_logging_level)
    get :refresh_logging, { :format => 'json' }
    response.status.should eq(401)
    response.body.blank?.should be_true
  end

  it "should not attempt to change log settings to a new bad config value" do
    session[:user_id] = @user_id
    Rails.env.stub(:production?).and_return(true)
    UserAuth.stub(:is_superuser?).with(@user_id).and_return(true)
    CalcentralConfig.stub(:load_settings).and_return(OpenStruct.new({logger: OpenStruct.new({level: 'fooz'})}))
    get :refresh_logging, { :format => 'json' }
    response.status.should eq(304)
    CalcentralConfig.stub(:load_settings).and_return(OpenStruct.new({logger: OpenStruct.new({level: 8})}))
    get :refresh_logging, { :format => 'json' }
    response.status.should eq(304)
  end

  it "should do nothing when the log level has not changed" do
    session[:user_id] = @user_id
    Rails.env.stub(:production?).and_return(true)
    UserAuth.stub(:is_superuser?).with(@user_id).and_return(true)
    CalcentralConfig.stub(:load_settings).and_return(OpenStruct.new({logger: OpenStruct.new({level: Rails.logger.level})}))
    get :refresh_logging, { :format => 'json' }
    response.status.should eq(304)
  end

  it "should succeed in changing the log level" do
    session[:user_id] = @user_id
    Rails.env.stub(:production?).and_return(true)
    UserAuth.stub(:is_superuser?).with(@user_id).and_return(true)
    Rails.logger.stub(:level).and_return(1)
    CalcentralConfig.stub(:load_settings).and_return(OpenStruct.new({logger: OpenStruct.new({level: 2})}))
    get :refresh_logging, { :format => 'json' }
    response.status.should eq(200)
    json_response = JSON.parse(response.body)
    json_response.blank?.should_not be_true
  end
end
