require "spec_helper"

describe FinalGradesEventProcessor do

  before do
    @processor = FinalGradesEventProcessor.new
  end

  it "should not handle an event type it doesn't know how to handle" do
    event = JSON.parse('{"id":"29592_5","system":"Bearfacts","code":"BlahType","payload":{"ccn":555,"term":"fall","year":2012}}')
    timestamp = Time.now.to_datetime
    @processor.process(event, timestamp).should == false
  end

  it "should handle an event given to it and save a notification with corresponding data" do
    event = JSON.parse('{"id":"29592_5","system":"Bearfacts","code":"EndOFTermGrade","payload":{"ccn":73974,"term":"fall","year":2012}}')
    timestamp = Time.now.to_datetime
    CampusData.stub(:get_enrolled_students, "73974").and_return(
        [
            {"ldap_uid" => "123456"},
            {"ldap_uid" => "323487"},
            {"ldap_uid" => "675750"},
            {"ldap_uid" => "730057"},
            {"ldap_uid" => "904715"},
            {"ldap_uid" => "978966"},
            {"ldap_uid" => "300846"}])
    CampusData.stub(:get_course_from_section, "73974").and_return(
        {"course_title" => "Research and Data Analysis in Psychology",
         "dept_name" => "PSYCH",
         "catalog_id" => "101"})

    UserData.stub(:where, "123456").and_return(MockUserData.new)

    Calcentral::USER_CACHE_EXPIRATION.should_receive(:notify).exactly(7).times

    @processor.process(event, timestamp).should == true

    saved_notification = Notification.where(:uid => "123456").first
    saved_notification.should_not be_nil
    saved_notification.data.should_not be_nil
    saved_notification.translator.should == "FinalGradesTranslator"
    saved_notification.occurred_at.to_i.should == timestamp.to_i
    Rails.logger.info "Saved notification's json is #{saved_notification.data}"

    Notification.where(:uid => "323487").first.data.should_not be_nil
    Notification.where(:uid => "300846").first.data.should_not be_nil

    translator_instance = saved_notification.translator.constantize.new
    translator_instance.should_not be_nil
    Rails.logger.info "Translated notification: #{translator_instance.translate saved_notification}"

  end

  it "should gracefully skip over a user that can't be found" do
    event = JSON.parse('{"id":"29592_5","system":"Bearfacts","code":"EndOFTermGrade","payload":{"ccn":73974,"term":"fall","year":2012}}')
    timestamp = Time.now.to_datetime
    CampusData.stub(:get_enrolled_students, "73974").and_return(
        [
            {"ldap_uid" => "123456"},
            {"ldap_uid" => "323487"},
            {"ldap_uid" => "675750"},
            {"ldap_uid" => "730057"},
            {"ldap_uid" => "904715"},
            {"ldap_uid" => "300846"},
            {"ldap_uid" => "978966"}])
    UserApi.should_not_receive(:delete)
    Calcentral::USER_CACHE_EXPIRATION.should_not_receive(:notify)
    UserData.stub(:where, "300846").and_return(NonexistentUserData.new)
    @processor.process(event, timestamp).should == true
  end

  it "should not save a duplicate event on the same day" do
    event = JSON.parse('{"id":"29592_5","system":"Bearfacts","code":"EndOFTermGrade","payload":{"ccn":73974,"term":"fall","year":2012}}')
    timestamp = Time.now.to_datetime
    CampusData.stub(:get_enrolled_students, "73974").and_return(
        [
            {"ldap_uid" => "123456"}])
    CampusData.stub(:get_course_from_section, "73974").and_return(
        {"course_title" => "Research and Data Analysis in Psychology",
         "dept_name" => "PSYCH",
         "catalog_id" => "101"})

    UserData.stub(:where, "123456").and_return(MockUserData.new)
    @processor.process(event, timestamp).should == true

    saved_notification = Notification.where(:uid => "123456").first
    saved_notification.should_not be_nil

    @processor.process(event, timestamp).should == false
  end

  it "should save multiple events on different days" do
    event = JSON.parse('{"id":"29592_5","system":"Bearfacts","code":"EndOFTermGrade","payload":{"ccn":73974,"term":"fall","year":2012}}')
    timestamp = Time.now.to_datetime
    CampusData.stub(:get_enrolled_students, "73974").and_return(
        [
            {"ldap_uid" => "123456"}])
    CampusData.stub(:get_course_from_section, "73974").and_return(
        {"course_title" => "Research and Data Analysis in Psychology",
         "dept_name" => "PSYCH",
         "catalog_id" => "101"})

    UserData.stub(:where, "123456").and_return(MockUserData.new)
    @processor.process(event, timestamp).should == true

    saved_notification = Notification.where(:uid => "123456").first
    saved_notification.should_not be_nil

    second_event = JSON.parse('{"id":"29592_5","system":"Bearfacts","code":"EndOFTermGrade","payload":{"ccn":73974,"term":"fall","year":2012}}')
    tomorrow = timestamp.advance(:days => 1)
    @processor.process(second_event, tomorrow).should == true

    saved_notifications = Notification.where(:uid => "123456")
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
