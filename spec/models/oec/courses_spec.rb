require "spec_helper"

describe Oec::Courses do

  let!(:random_time) { Time.now.to_f.to_s.gsub(".", "") }

  context "the exported file in the tmp directory" do
    let!(:spec_file) { CSV.read("fixtures/oec/courses.csv") }

    before(:each) {
      all_courses_query = []
      spec_file.each_with_index do |row, index|
        if index > 0
          all_courses_query << {
            "COURSE_ID" => row[0],
            "COURSE_NAME" => row[1],
            "CROSS_LISTED_FLAG" => row[2],
            "CROSS_LISTED_NAME" => row[3],
            "DEPT_NAME" => row[4],
            "CATALOG_ID" => row[5],
            "INSTRUCTION_FORMAT" => row[6],
            "SECTION_NUM" => row[7],
            "PRIMARY_SECONDARY_CD" => row[8],
            "EVALUATE" => row[9],
            "EVALUATION_TYPE" => row[10],
            "MODULAR_COURSE" => row[11],
            "START_DATE" => row[12],
            "END_DATE" => row[13]
          }
        end
      end
      Oec::Queries.stub(:get_all_courses).and_return(all_courses_query)
    }

    let!(:export) { Oec::Courses.new.export(random_time) }

    subject { CSV.read(export[:filename]) }
    it {
      should_not be_nil
      should eq(spec_file)
    }
  end

  context "special mangling of cross-listed course names" do
    before(:each) {
      Oec::Queries.stub(:get_all_courses).and_return(
        [
          {
            "course_id" => "abcdef",
            "course_name" => "cross listing 101",
            "cross_listed_flag" => "Y",
            "cross_listed_name" => "12345,67890",
            "dept_name" => "TEST",
            "catalog_id" => "TEST 101C",
            "instruction_format" => "LEC",
            "section_num" => "001",
            "primary_secondary_cd" => "",
            "evaluate" => nil,
            "evaluation_type" => nil,
            "modular_course" => nil,
            "start_date" => nil,
            "end_date" => nil,
            "course_title_short" => "XLIST 101"
          }])
    }

    let!(:export) { Oec::Courses.new.export(random_time) }

    subject { CSV.read(export[:filename]) }
    it {
      should_not be_nil
      p "subject = #{subject}"
      subject[0][3].should == "CROSS_LISTED_NAME"
      subject[1][3].should == "XLIST 101 (12345,67890)"
    }
  end
end
