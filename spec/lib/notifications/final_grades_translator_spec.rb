require "spec_helper"

describe FinalGradesTranslator do

  it "should translate a final-grades event properly" do
    user = UserApi.new "123456"
    user.record_first_login
    event = JSON.parse('{"id":"29592_5","system":"Bearfacts","code":"EndOFTermGrade","payload":{"ccn":73974,"term":"fall","year":2012}}')
    timestamp = Time.now.to_datetime
    CampusData.stub(:get_enrolled_students, "73974").and_return(
        [{"ldap_uid" => "123456"}])
    CampusData.stub(:get_course_from_section, "73974").and_return(
        {"course_title" => "Research and Data Analysis in Psychology",
         "dept_name" => "PSYCH",
         "catalog_id" => "101"
        }
    )

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
