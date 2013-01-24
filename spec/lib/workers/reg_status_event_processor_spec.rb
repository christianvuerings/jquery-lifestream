require "spec_helper"

describe RegStatusEventProcessor do

  before do
    @processor = RegStatusEventProcessor.new
  end

  it "should not handle an event type it doesn't know how to handle" do
    event = JSON.parse('{"id":"42341_1","system":"Bearfacts Testing System","code":"UnknownType","payload":{"uid":300846}}')
    timestamp = Time.now.to_datetime
    @processor.process(event, timestamp).should == false
  end

  it "should handle an event given to it and save a notification with corresponding data" do
    event = JSON.parse('{"id":"42341_1","system":"Bearfacts Testing System","code":"RegStatus","payload":{"uid":300846}}')
    timestamp = Time.now.to_datetime
    CampusData.stub(:get_reg_status, "300846").and_return({
        "ldap_uid" => "300846",
        "reg_status_cd" => "C",
        "on_probation_flag" => "N"
    })
    @processor.process(event, timestamp).should == true

    saved_notification = Notification.where(:uid => "300846").first
    saved_notification.should_not be_nil
    saved_notification.data.should_not be_nil
    Rails.logger.info "Saved notification's json is #{saved_notification.data}"
    saved_notification.data["date"]["epoch"].should == timestamp.to_i
    saved_notification.data["date"]["datetime"].should_not be_nil
    saved_notification.data["source"].should == "Bearfacts Testing System"
    saved_notification.data["title"].should == "Your UC Berkeley student registration status has been updated to: \"registered, continuing.\" You are an active registered student in your second or subsequent semester. If you have a question about your registration status change, please contact the Office of the Registrar. orweb@berkeley.edu"

  end

end
