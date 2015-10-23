describe Notifications::RegStatusTranslator do

  it "should translate a reg-status event properly" do
    user = User::Api.new "300846"
    user.record_first_login
    processor = Notifications::RegStatusEventProcessor.new
    event = JSON.parse('{"topic":"Bearfacts:RegStatus","timestamp":"2013-05-30T07:15:09.191-07:00","payload":{"uid":[300846,300847]}}')
    timestamp = Time.now.to_datetime
    CampusOracle::Queries.stub(:get_reg_status).and_return(
      {
        "ldap_uid" => "300846",
        "reg_status_cd" => "C"
      })
    processor.process(event, timestamp).should == true

    saved_notification = Notifications::Notification.where(:uid => "300846").first

    translator = Notifications::RegStatusTranslator.new
    translated = translator.translate saved_notification

    translated[:date][:epoch].should == timestamp.to_time.to_i
    translated[:date][:dateTime].should_not be_nil
    translated[:source].should == "Bear Facts"
    translated[:title].should == "Registration status updated to: Registered"
    translated[:summary].should == "You are officially registered for this term and are entitled to access campus services. If you have a question about your registration status change, please contact the Office of the Registrar. orweb@berkeley.edu"
  end
end
