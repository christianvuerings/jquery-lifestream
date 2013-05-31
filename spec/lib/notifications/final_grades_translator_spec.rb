require "spec_helper"

describe FinalGradesTranslator do

  it "should translate a final-grades event properly" do
    user = UserApi.new "123456"
    user.record_first_login
    event = JSON.parse('{"topic":"Bearfacts:EndOfTermGrades","timestamp":"2013-05-30T07:15:11.871-07:00","payload":{"course":[{"ccn":73974,"term":{"year":2013,"name":"C"}},{"ccn":7366,"term":{"year":2013,"name":"C"}}]}}')
    timestamp = Time.now.to_datetime
    CampusData.stub(:get_enrolled_students).with(73974, 2013, 'C').and_return([{"ldap_uid" => "123456"}])
    CampusData.stub(:get_enrolled_students).with(7366, 2013, 'C').and_return([])
    CampusData.stub(:get_course_from_section).and_return(
      {"course_title" => "Research and Data Analysis in Psychology",
       "dept_name" => "PSYCH",
       "catalog_id" => "101"
      })
    CampusData.stub(:get_course_from_section).with(7366, 2013, 'C').and_return(
      {"course_title" => "Intro to Nuclear English",
       "dept_name" => "ENGL",
       "catalog_id" => "1"})

    processor = FinalGradesEventProcessor.new
    processor.process(event, timestamp)

    notification = Notification.where(:uid => "123456").first
    translator = FinalGradesTranslator.new
    translated = translator.translate notification
    Rails.logger.info "Translated notification = #{translated}"
    translated[:title].should == "Final grades posted for PSYCH 101"
    translated[:date][:date_time].should_not be_nil
    translated[:date][:epoch].should == timestamp.to_i
  end
end
