require "spec_helper"

describe RegStatusTranslator do

  it "should translate a reg-status event properly" do
    user = UserApi.new "300846"
    user.record_first_login
    processor = RegStatusEventProcessor.new
    event = JSON.parse('{"id":"42341_1","system":"Bearfacts Testing System","code":"RegStatus","payload":{"uid":300846}}')
    timestamp = Time.now.to_datetime
    CampusData.stub(:get_reg_status, "300846").and_return({
                                                              "ldap_uid" => "300846",
                                                              "reg_status_cd" => "C"
                                                          })
    processor.process(event, timestamp).should == true

    saved_notification = Notification.where(:uid => "300846").first

    translator = RegStatusTranslator.new
    translated = translator.translate saved_notification

    translated[:date][:epoch].should == timestamp.to_i
    translated[:date][:datetime].should_not be_nil
    translated[:source].should == "Bearfacts Testing System"
    translated[:title].should == "Your UC Berkeley student registration status has been updated to: REGISTERED. You are officially registered for this term and are entitled to access campus services. If you have a question about your registration status change, please contact the Office of the Registrar. orweb@berkeley.edu"

  end
end
