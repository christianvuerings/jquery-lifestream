require "spec_helper"

describe RefreshLoggingController do
  before(:each) do
    @user_id = rand(99999).to_s
  end

  it "should not allow non-admin users to do anything to the logging level" do
    session['user_id'] = @user_id
    User::Auth.stub(:where).and_return([User::Auth.new(uid: @user_id, is_superuser: false, active: true)])
    Rails.env.stub(:production?).and_return(true)
    CalcentralLogging.should_not_receive(:refresh_logging_level)
    get :refresh_logging, { :format => 'json' }
    expect(response.status).to eq(403)
    expect(response.body.blank?).to be_truthy
  end

  it "should not attempt to change log settings to a new bad config value" do
    session['user_id'] = @user_id
    Rails.env.stub(:production?).and_return(true)
    User::Auth.stub(:where).and_return([User::Auth.new(uid: @user_id, is_superuser: true, active: true)])
    CalcentralConfig.stub(:load_settings).and_return(OpenStruct.new({logger: OpenStruct.new({level: 'fooz'})}))
    get :refresh_logging, { :format => 'json' }
    expect(response.status).to eq(304)
    CalcentralConfig.stub(:load_settings).and_return(OpenStruct.new({logger: OpenStruct.new({level: 8})}))
    get :refresh_logging, { :format => 'json' }
    expect(response.status).to eq(304)
  end

  it "should do nothing when the log level has not changed" do
    session['user_id'] = @user_id
    Rails.env.stub(:production?).and_return(true)
    User::Auth.stub(:where).and_return([User::Auth.new(uid: @user_id, is_superuser: true, active: true)])
    CalcentralConfig.stub(:load_settings).and_return(OpenStruct.new({logger: OpenStruct.new({level: Rails.logger.level})}))
    get :refresh_logging, { :format => 'json' }
    expect(response.status).to eq(304)
  end

  it "should succeed in changing the log level" do
    session['user_id'] = @user_id
    Rails.env.stub(:production?).and_return(true)
    User::Auth.stub(:where).and_return([User::Auth.new(uid: @user_id, is_superuser: true, active: true)])
    Rails.logger.stub(:level).and_return(1)
    CalcentralConfig.stub(:load_settings).and_return(OpenStruct.new({logger: OpenStruct.new({level: 2})}))
    get :refresh_logging, { :format => 'json' }
    expect(response.status).to eq(200)
    json_response = JSON.parse(response.body)
    expect(json_response.blank?).to be_falsey
  end
end
