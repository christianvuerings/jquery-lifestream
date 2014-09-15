require "spec_helper"

describe User::Api do
  before(:each) do
    @random_id = Time.now.to_f.to_s.gsub(".", "")
    @default_name = "Joe Default"
    CampusOracle::UserAttributes.stub(:new).and_return(double(get_feed: {
      'person_name' => @default_name,
      :roles => {
        :student => true,
        :exStudent => false,
        :faculty => false,
        :staff => false
      }
    }))
  end

  it "should find user with default name" do
    u = User::Api.new(@random_id)
    u.init
    u.preferred_name.should == @default_name
  end
  it "should override the default name" do
    u = User::Api.new(@random_id)
    u.update_attributes(preferred_name: "Herr Heyer")
    u = User::Api.new(@random_id)
    u.init
    u.preferred_name.should == "Herr Heyer"
  end
  it "should revert to the default name" do
    u = User::Api.new(@random_id)
    u.update_attributes(preferred_name: "Herr Heyer")
    u = User::Api.new(@random_id)
    u.update_attributes(preferred_name: "")
    u = User::Api.new(@random_id)
    u.init
    u.preferred_name.should == @default_name
  end
  it "should return a user data structure" do
    user_data = User::Api.new(@random_id).get_feed
    user_data[:preferred_name].should == @default_name
    user_data[:hasCanvasAccount].should_not be_nil
    user_data[:isCalendarOptedIn].should_not be_nil
  end
  it "should return whether the user is registered with Canvas" do
    Canvas::Proxy.stub(:has_account?).and_return(true, false)
    user_data = User::Api.new(@random_id).get_feed
    user_data[:hasCanvasAccount].should be_true
    Rails.cache.clear
    user_data = User::Api.new(@random_id).get_feed
    user_data[:hasCanvasAccount].should be_false
  end
  it "should have a null first_login time for a new user" do
    user_data = User::Api.new(@random_id).get_feed
    user_data[:firstLoginAt].should be_nil
  end
  it "should properly register a call to record_first_login" do
    user_api = User::Api.new(@random_id)
    user_api.get_feed
    user_api.record_first_login
    updated_data = user_api.get_feed
    updated_data[:firstLoginAt].should_not be_nil
  end
  it "should delete a user and all his dependent parts" do
    user_api = User::Api.new @random_id
    user_api.record_first_login
    user_api.get_feed

    User::Oauth2Data.should_receive(:destroy_all)
    Notifications::Notification.should_receive(:destroy_all)
    Cache::UserCacheExpiry.should_receive(:notify)
    Calendar::User.should_receive(:delete_all)

    User::Api.delete @random_id

    User::Data.where(:uid => @random_id).should == []
  end

  it "should say random student gets the academics tab", if: CampusOracle::Queries.test_data? do
    user_data = User::Api.new(@random_id).get_feed
    user_data[:hasAcademicsTab].should be_true
  end

  it "should say a staff member with no academic history does not get the academics tab", if: CampusOracle::Queries.test_data? do
    CampusOracle::UserAttributes.stub(:new).and_return(double(get_feed: {
      'person_name' => @default_name,
      :roles => {
        :student => false,
        :faculty => false,
        :staff => true
      }
    }))
    fake_instructor_proxy = CampusOracle::UserCourses::HasInstructorHistory.new({:fake => true})
    fake_instructor_proxy.stub(:has_instructor_history?).and_return(false)
    CampusOracle::UserCourses::HasInstructorHistory.stub(:new).and_return(fake_instructor_proxy)
    fake_student_proxy = CampusOracle::UserCourses::HasStudentHistory.new({:fake => true})
    fake_student_proxy.stub(:has_student_history?).and_return(false)
    CampusOracle::UserCourses::HasStudentHistory.stub(:new).and_return(fake_student_proxy)
    user_data = User::Api.new("904715").get_feed
    user_data[:hasAcademicsTab].should be_false
  end

  describe "my finances tab" do
    let(:student_roles) do
      {
        :active   => { :student => true,  :exStudent => false, :faculty => false, :staff => false },
        :expired  => { :student => false, :exStudent => true,  :faculty => false, :staff => false },
        :non      => { :student => false, :exStudent => false, :faculty => false, :staff => true },
      }
    end
    before do
      allow(CampusOracle::UserAttributes).to receive(:new).and_return(double(get_feed: {
        roles: test_roles
      }))
    end
    subject {User::Api.new(@random_id).get_feed[:hasFinancialsTab]}
    context 'an active student' do
      let(:test_roles) {student_roles[:active]}
      it {should be_true}
    end
    context 'a non-student' do
      let(:test_roles) {student_roles[:non]}
      it {should be_false}
    end
    context 'an ex-student' do
      let(:test_roles) {student_roles[:expired]}
      it {should be_true}
    end
  end


  it "should not explode when CampusOracle returns empty feeds" do
    CampusOracle::UserAttributes.stub(:new).and_return(double(get_feed: {
    }))
    fake_instructor_proxy = CampusOracle::UserCourses::HasInstructorHistory.new({:fake => true})
    fake_instructor_proxy.stub(:has_instructor_history?).and_return(false)
    CampusOracle::UserCourses::HasInstructorHistory.stub(:new).and_return(fake_instructor_proxy)
    fake_student_proxy = CampusOracle::UserCourses::HasStudentHistory.new({:fake => true})
    fake_student_proxy.stub(:has_student_history?).and_return(false)
    CampusOracle::UserCourses::HasStudentHistory.stub(:new).and_return(fake_student_proxy)
    user_data = User::Api.new("904715").get_feed
    user_data[:hasAcademicsTab].should_not be_true
  end

  context "proper cache handling" do

    it "should update the last modified hash when content changes" do
      user_api = User::Api.new(@random_id)
      user_api.get_feed
      original_last_modified = User::Api.get_last_modified(@random_id)
      old_hash = original_last_modified[:hash]
      old_timestamp = original_last_modified[:timestamp]

      sleep 1

      user_api.preferred_name="New Name"
      user_api.save
      feed = user_api.get_feed
      new_last_modified = User::Api.get_last_modified(@random_id)
      new_last_modified[:hash].should_not == old_hash
      new_last_modified[:timestamp].should_not == old_timestamp
      new_last_modified[:timestamp][:epoch].should == feed[:lastModified][:timestamp][:epoch]
    end

    it "should not update the last modified hash when content hasn't changed" do
      user_api = User::Api.new(@random_id)
      user_api.get_feed
      original_last_modified = User::Api.get_last_modified(@random_id)

      sleep 1

      Cache::UserCacheExpiry.notify @random_id
      feed = user_api.get_feed
      unchanged_last_modified = User::Api.get_last_modified(@random_id)
      original_last_modified.should == unchanged_last_modified
      original_last_modified[:timestamp][:epoch].should == feed[:lastModified][:timestamp][:epoch]
    end

  end

  context "proper handling of superuser permissions" do
    before { User::Auth.new_or_update_superuser!(@random_id) }
    subject { User::Api.new(@random_id).get_feed }
    it "should pass the superuser status" do
      subject[:isSuperuser].should be_true
      subject[:isViewer].should be_true
    end
  end

  context "proper handling of viewer permissions" do
    before {
      user = User::Auth.new(uid: @random_id)
      user.is_viewer = true
      user.active = true
      user.save
    }
    subject { User::Api.new(@random_id).get_feed }
    it "should pass the viewer status" do
      subject[:isSuperuser].should be_false
      subject[:isViewer].should be_true
    end
  end

end

