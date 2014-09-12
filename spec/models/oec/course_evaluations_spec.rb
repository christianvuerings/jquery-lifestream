require "spec_helper"

describe Oec::CourseEvaluations do

  let!(:random_time) { Time.now.to_f.to_s.gsub(".", "") }

  context "exported file in tmp directory" do
    let!(:spec_file) { CSV.read("fixtures/oec/course_evaluations.csv") }

    before(:each) {
      all_course_evaluations_query = []
      spec_file.each_with_index do |row, index|
        if index > 0
          all_course_evaluations_query << {
            "COURSE_ID" => row[0],
            "COURSE_NAME" => row[1],
            "CROSS_LISTED_FLAG" => row[2],
            "CROSS_LISTED_NAME" => row[3],
            "DEPT_NAME" => row[4],
            "CATALOG_ID" => row[5],
            "INSTRUCTION_FORMAT" => row[6],
            "SECTION_NUM" => row[7],
            "PRIMARY_SECONDARY_CD" => row[8],
            "LDAP_UID" => row[9],
            "FIRST_NAME" => row[10],
            "LAST_NAME" => row[11],
            "EMAIL_ADDRESS" => row[12],
            "INSTRUCTOR_FUNC" => row[13],
            "BLUE_ROLE" => row[14],
            "EVALUATE" => row[15],
            "EVALUATION_TYPE" => row[16],
            "MODULAR_COURSE" => row[17],
            "START_DATE" => row[18],
            "END_DATE" => row[19]
          }
        end
      end
      Oec::Queries.stub(:get_all_course_evaluations).and_return(all_course_evaluations_query)
    }

    let!(:export) { Oec::CourseEvaluations.new.export(random_time) }

    subject { CSV.read(export[:filename]) }
    it {
      should_not be_nil
      should eq(spec_file)
    }
  end

end
