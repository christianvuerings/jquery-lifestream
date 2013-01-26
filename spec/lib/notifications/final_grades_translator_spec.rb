require "spec_helper"

describe FinalGradesTranslator do

  it "should translate a final-grades event properly" do
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
    CampusData.stub(:get_course, "73974").and_return(
        {"course_title" => "Research and Data Analysis in Psychology"}
    )

    processor = FinalGradesEventProcessor.new
    processor.process(event, timestamp)

    notification = Notification.where(:uid => "123456").first
    translator = FinalGradesTranslator.new
    translated = translator.translate notification
    Rails.logger.info "Translated notification = #{translated}"

  end
end
