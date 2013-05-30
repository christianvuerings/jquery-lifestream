require "spec_helper"

describe RegStatusEventProcessor do

  before do
    @processor = RegStatusEventProcessor.new
  end

  it "should not handle an event topic it doesn't know how to handle" do
    event = JSON.parse('{"topic":"Bearfallacies:RegStatus","timestamp":"2013-05-30T07:15:09.191-07:00","payload":{"uid":[300846,300847]}}')
    timestamp = Time.now.to_datetime
    @processor.process(event, timestamp).should == false
  end

  it "should handle an event given to it and save a notification with corresponding data" do
    event = JSON.parse('{"topic":"Bearfacts:RegStatus","timestamp":"2013-05-30T07:15:09.191-07:00","payload":{"uid":[300846,300847]}}')
    timestamp = Time.now.to_datetime
    CampusData.stub(:get_reg_status).with(300846).and_return(
        {
            "ldap_uid" => "300846",
            "reg_status_cd" => "C"
        })
    CampusData.stub(:get_reg_status).with(300847).and_return(nil)
    UserApi.should_not_receive(:delete)
    Calcentral::USER_CACHE_EXPIRATION.should_receive(:notify).once
    UserData.stub(:where).with({:uid =>"300846"}).and_return(MockUserData.new)

    @processor.process(event, timestamp).should == true

    saved_notification = Notification.where(:uid => "300846").first
    saved_notification.should_not be_nil
    saved_notification.data.should_not be_nil
    saved_notification.translator.should == "RegStatusTranslator"
    saved_notification.occurred_at.to_i.should == timestamp.to_i
    Rails.logger.info "Saved notification's json is #{saved_notification.data}"
    translator_instance = saved_notification.translator.constantize.new
    translator_instance.should_not be_nil
    Rails.logger.info "Translated notification: #{translator_instance.translate saved_notification}"

  end

  it "should skip an event and do nothing if the reg_status can't be found" do
    event = JSON.parse('{"topic":"Bearfacts:RegStatus","timestamp":"2013-05-30T07:15:09.191-07:00","payload":{"uid":[300846,300847]}}')
    timestamp = Time.now.to_datetime
    CampusData.stub(:get_reg_status).and_return(nil)
    @processor.process(event, timestamp).should == false
  end

  it "should skip an event if the user exists but doesn't have a reg status" do
    event = JSON.parse('{"topic":"Bearfacts:RegStatus","timestamp":"2013-05-30T07:15:09.191-07:00","payload":{"uid":[2040,95509]}}')
    timestamp = Time.now.to_datetime
    @processor.process(event, timestamp).should == false
  end

  it "should remove a deceased student from the system" do
    UserApi.should_receive(:delete)

    event = JSON.parse('{"topic":"Bearfacts:RegStatus","timestamp":"2013-05-30T07:15:09.191-07:00","payload":{"uid":[300846,300847]}}')
    timestamp = Time.now.to_datetime
    CampusData.stub(:get_reg_status).with(300846).and_return(
        {
            "ldap_uid" => "300846",
            "reg_status_cd" => "Z"
        })
    CampusData.stub(:get_reg_status).with(300847).and_return(
      {
        "ldap_uid" => "300847",
        "reg_status_cd" => "C"
      })
    @processor.process(event, timestamp).should == true

  end

  it "should gracefully skip over a user that can't be found" do
    event = JSON.parse('{"topic":"Bearfacts:RegStatus","timestamp":"2013-05-30T07:15:09.191-07:00","payload":{"uid":[300846,300847]}}')
    timestamp = Time.now.to_datetime
    CampusData.stub(:get_reg_status).and_return(
        {
            "ldap_uid" => "300846",
            "reg_status_cd" => "C",
            "on_probation_flag" => "N"
        })
    UserApi.should_not_receive(:delete)
    Calcentral::USER_CACHE_EXPIRATION.should_not_receive(:notify)
    UserData.stub(:where).and_return(NonexistentUserData.new)
    @processor.process(event, timestamp).should == true
  end

  it "should not record multiple events on the same day" do
    event = JSON.parse('{"topic":"Bearfacts:RegStatus","timestamp":"2013-05-30T07:15:09.191-07:00","payload":{"uid":[300846,300847]}}')
    timestamp = Time.now.to_datetime
    CampusData.stub(:get_reg_status).and_return(
        {
            "ldap_uid" => "300846",
            "reg_status_cd" => "C"
        })
    UserData.stub(:where).and_return(MockUserData.new)
    @processor.process(event, timestamp).should == true
    saved_notification = Notification.where(:uid => "300846").first
    saved_notification.should_not be_nil

    second_event = JSON.parse('{"topic":"Bearfacts:RegStatus","timestamp":"2013-05-30T07:15:09.191-07:00","payload":{"uid":[300846,300847]}}')
    @processor.process(second_event, timestamp).should == false
  end

  it "should record multiple events on different days" do
    event = JSON.parse('{"topic":"Bearfacts:RegStatus","timestamp":"2013-05-30T07:15:09.191-07:00","payload":{"uid":[300846,300847]}}')
    timestamp = Time.now.to_datetime
    CampusData.stub(:get_reg_status).and_return(
        {
            "ldap_uid" => "300846",
            "reg_status_cd" => "C"
        })
    UserData.stub(:where).and_return(MockUserData.new)
    @processor.process(event, timestamp).should == true
    saved_notification = Notification.where(:uid => "300846").first
    saved_notification.should_not be_nil
    Notification.where(:uid => "300847").first.should_not be_nil

    second_event = JSON.parse('{"topic":"Bearfacts:RegStatus","timestamp":"2013-05-31T07:15:09.191-07:00","payload":{"uid":[300846,300847]}}')
    tomorrow = Time.now.to_datetime.advance(:days=>1)
    @processor.process(second_event, tomorrow).should == true
    saved_notifications = Notification.where(:uid => "300846")
    saved_notifications.length.should == 2
  end


  class MockUserData
    def exists?
      true
    end
  end

  class NonexistentUserData
    def exists?
      false
    end
  end
end
