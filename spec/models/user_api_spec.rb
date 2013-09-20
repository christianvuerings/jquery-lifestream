require "spec_helper"

describe "UserApi" do
  before(:each) do
    @random_id = Time.now.to_f.to_s.gsub(".", "")
    @default_name = "Joe Default"
    CampusData.stub(:get_person_attributes) do |uid|
      if uid == @random_id
        {'person_name' => @default_name}
      else
        {}
      end
    end
  end

  it "should find user with default name" do
    u = UserApi.new(@random_id)
    u.init
    u.preferred_name.should == @default_name
  end
  it "should override the default name" do
    u = UserApi.new(@random_id)
    u.update_attributes(preferred_name: "Herr Heyer")
    u = UserApi.new(@random_id)
    u.init
    u.preferred_name.should == "Herr Heyer"
  end
  it "should revert to the default name" do
    u = UserApi.new(@random_id)
    u.update_attributes(preferred_name: "Herr Heyer")
    u = UserApi.new(@random_id)
    u.update_attributes(preferred_name: "")
    u = UserApi.new(@random_id)
    u.init
    u.preferred_name.should == @default_name
  end
  it "should return a user data structure" do
    user_data = UserApi.new(@random_id).get_feed
    user_data[:preferred_name].should == @default_name
    user_data[:has_canvas_account].should_not be_nil
  end
  it "should return whether the user is registered with Canvas" do
    CanvasProxy.stub(:has_account?).and_return(true, false)
    user_data = UserApi.new(@random_id).get_feed
    user_data[:has_canvas_account].should be_true
    Rails.cache.clear
    user_data = UserApi.new(@random_id).get_feed
    user_data[:has_canvas_account].should be_false
  end
  it "should have a null first_login time for a new user" do
    user_data = UserApi.new(@random_id).get_feed
    user_data[:first_login_at].should be_nil
  end
  it "should properly register a call to record_first_login" do
    user_api = UserApi.new(@random_id)
    user_api.get_feed
    user_api.record_first_login
    updated_data = user_api.get_feed
    updated_data[:first_login_at].should_not be_nil
  end
  it "should delete a user and all his dependent parts" do
    user_api = UserApi.new @random_id
    user_api.record_first_login
    user_api.get_feed

    Oauth2Data.should_receive(:destroy_all)
    Notification.should_receive(:destroy_all)
    Calcentral::USER_CACHE_EXPIRATION.should_receive(:notify)

    UserApi.delete @random_id

    UserData.where(:uid => @random_id).should == []
  end
  it "should say everyone is allowed to log in if the whitelist is disabled" do
    UserApi.is_allowed_to_log_in?("0").should == true
  end
  it "should say a user who's already logged in is ok to log in" do
    Settings.features.user_whitelist = true
    user_api = UserApi.new @random_id
    user_api.record_first_login
    UserApi.is_allowed_to_log_in?(@random_id).should == true
  end
  it "should say a user in the explicit whitelist is ok to log in" do
    Settings.features.user_whitelist = true
    UserWhitelist.where(uid: @random_id).first_or_create
    UserApi.is_allowed_to_log_in?(@random_id).should == true
  end
  it "should say a user with a canvas account is ok to log in" do
    Settings.features.user_whitelist = true
    CanvasProxy.stub(:has_account?).and_return(true)
    UserApi.is_allowed_to_log_in?(@random_id).should == true
  end
  it "should say a user who hasn't logged in, has no canvas acct, and isn't in the whitelist cannot log in" do
    Settings.features.user_whitelist = true
    CanvasProxy.stub(:has_account?).and_return(false)
    UserApi.is_allowed_to_log_in?("0").should == false
  end
  it "should say a freshman undergrad can log in" do
    Settings.features.user_whitelist = true
    CanvasProxy.stub(:has_account?).and_return(false)
    CampusData.stub(:get_student_info).and_return(
      {
        "first_reg_term_cd" => "D",
        "first_reg_term_yr" => "2013"
      })
    UserApi.is_allowed_to_log_in?(@random_id).should == true
  end
  it "should say a junior undergrad cannot log in" do
    Settings.features.user_whitelist = true
    CanvasProxy.stub(:has_account?).and_return(false)
    CampusData.stub(:get_student_info).and_return(
      {
        "first_reg_term_cd" => "D",
        "first_reg_term_yr" => "2011"
      })
    UserApi.is_allowed_to_log_in?(@random_id).should == false
  end

  it "grad students who used to be undergrads can log in", if: CampusData.test_data? do
    Settings.features.user_whitelist = true
    CanvasProxy.stub(:has_account?).and_return(false)
    UserApi.is_allowed_to_log_in?("212388").should be_true
    UserApi.is_allowed_to_log_in?("212389").should be_false
    UserApi.is_allowed_to_log_in?("212390").should be_false
  end

  context "proper cache handling" do
    it "should cache the feed" do
      UserApi.should_receive(:fetch_from_cache).with(@random_id)
      UserApi.new(@random_id).get_feed
    end

    it "should update the last modified hash when content changes" do
      user_api = UserApi.new(@random_id)
      user_api.get_feed
      original_last_modified = UserApi.get_last_modified(@random_id)

      sleep 1

      user_api.preferred_name="New Name"
      user_api.save
      user_api.get_feed
      new_last_modified = UserApi.get_last_modified(@random_id)
      new_last_modified[:hash].should_not == original_last_modified[:hash]
      new_last_modified[:timestamp].should_not == original_last_modified[:timestamp]
    end

    it "should not update the last modified hash when content hasn't changed" do
      user_api = UserApi.new(@random_id)
      user_api.get_feed
      original_last_modified = UserApi.get_last_modified(@random_id)

      sleep 1

      Calcentral::USER_CACHE_EXPIRATION.notify @random_id
      user_api.get_feed
      unchanged_last_modified = UserApi.get_last_modified(@random_id)
      original_last_modified.should == unchanged_last_modified
    end

  end

  context "valid regblocks" do
    let! (:oski_blocks_proxy) { BearfactsRegblocksProxy.new({:user_id => "61889", :fake => true}) }
    before do
      BearfactsProxy.any_instance.stub(:lookup_student_id).and_return(11667051)
      BearfactsRegblocksProxy.stub(:new).and_return(oski_blocks_proxy)
    end

    subject { UserApi.new("61889").get_feed[:student_info] }

    it "should return some active_blocks" do
      subject[:reg_block].should be_present
      subject[:reg_block][:active_blocks].should be_present
      subject[:reg_block][:active_blocks].should > 0
    end

    it "bearfacts API should be online" do
      subject[:reg_block][:available].should be_true
    end

    it "needsAction should be true" do
      subject[:reg_block][:needsAction].should be_true
    end

  end

  context "invalid/offline regblock" do
    before { BearfactsRegblocksProxy.any_instance.stub(:get).and_return {} }

    subject { UserApi.new("61889").get_feed[:student_info] }
    it "should have no active blocks" do
      subject[:reg_block].should be_present
      subject[:reg_block][:active_blocks].should be_present
      subject[:reg_block][:active_blocks].should eq(0)
    end

    it "bearfacts API should be offline" do
      subject[:reg_block][:available].should be_false
    end

    it "needsAction should be false" do
      subject[:reg_block][:needsAction].should be_false
    end
  end
end
