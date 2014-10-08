require "spec_helper"

describe Berkeley::CoursePolicy do
  let(:user_id)     { rand(99999).to_s }
  let(:user)        { AuthenticationState.new(user_id: user_id) }
  let(:course)      { Berkeley::Course.new(:course_id => "chem-1a-2014-D") }
  let(:instructor_courses) do
    {
      "2014-D" => [
        {
          :id=>"chem-1a-2014-D",
          :slug=>"chem-1a",
          :course_code=>"CHEM 1A",
          :term_yr=>"2014",
          :term_cd=>"D",
          :dept=>"CHEM",
          :dept_desc=>"Chemistry",
          :catid=>"1A",
          :course_catalog=>"1A",
          :emitter=>"Campus",
          :name=>"General Chemistry",
          :sections=>[
            {:ccn=>"11003", :instruction_format=>"LEC", :is_primary_section=>true, :section_label=>"LEC 001", :section_number=>"001", :unit=>nil, :pnp_flag=>nil, :cred_cd=>nil, :schedules=>[{:buildingName=>"PIMENTEL", :roomNumber=>"1", :schedule=>"MWF 9:00A-10:00A"}], :instructors=>[{:name=>"John Smith", :uid=>user_id}]},
            {:ccn=>"11012", :instruction_format=>"DIS", :is_primary_section=>false, :section_label=>"DIS 101", :section_number=>"101", :schedules=>[{:buildingName=>"HILDEBRAND", :roomNumber=>"100D", :schedule=>"M 10:00A-11:00A"}], :instructors=>[]},
            {:ccn=>"11015", :instruction_format=>"DIS", :is_primary_section=>false, :section_label=>"DIS 102", :section_number=>"102", :schedules=>[{:buildingName=>"HILDEBRAND", :roomNumber=>"100F", :schedule=>"M 10:00A-11:00A"}], :instructors=>[]},
            {:ccn=>"11018", :instruction_format=>"DIS", :is_primary_section=>false, :section_label=>"DIS 103", :section_number=>"103", :schedules=>[{:buildingName=>"HILDEBRAND", :roomNumber=>"100D", :schedule=>"M 12:00P-1:00P"}], :instructors=>[]},
          ],
          :course_option=>"A1",
          :role=>"Instructor"
        }
      ],
      "2014-C" => [
        {
          :id=>"chem-196-2014-C",
          :slug=>"chem-196",
          :course_code=>"CHEM 196",
          :term_yr=>"2014",
          :term_cd=>"C",
          :dept=>"CHEM",
          :dept_desc=>"Chemistry",
          :catid=>"196",
          :course_catalog=>"196",
          :emitter=>"Campus",
          :name=>"Special Laboratory Study",
          :sections=>[
            {:ccn=>"22795",:instruction_format=>"IND", :is_primary_section=>true, :section_label=>"IND 003", :section_number=>"003", :unit=>nil, :pnp_flag=>nil, :cred_cd=>nil, :schedules=>[], :instructors=>[{:name=>"John Smith", :uid=>user_id}]}
          ],
          :course_option=>"A1",
          :role=>"Instructor"
        }
      ],
    }
  end

  let(:student_courses) do
    {
      "2014-D" => [
        {
          :id=>"chem-1a-2014-D",
          :slug=>"chem-1a",
          :course_code=>"CHEM 1A",
          :term_yr=>"2014",
          :term_cd=>"D",
          :dept=>"CHEM",
          :dept_desc=>"Chemistry",
          :catid=>"1A",
          :course_catalog=>"1A",
          :emitter=>"Campus",
          :name=>"General Chemistry",
          :sections=>[
            {:ccn=>"11003", :instruction_format=>"LEC", :is_primary_section=>true, :section_label=>"LEC 001", :section_number=>"001", :unit=>nil, :pnp_flag=>nil, :cred_cd=>nil, :schedules=>[{:buildingName=>"PIMENTEL", :roomNumber=>"1", :schedule=>"MWF 9:00A-10:00A"}], :instructors=>[{:name=>"John Smith", :uid=>user_id}]},
            {:ccn=>"11015", :instruction_format=>"DIS", :is_primary_section=>false, :section_label=>"DIS 102", :section_number=>"102", :schedules=>[{:buildingName=>"HILDEBRAND", :roomNumber=>"100F", :schedule=>"M 10:00A-11:00A"}], :instructors=>[]},
          ],
          :role=>"Student"
        }
      ],
      "2014-C" => [
        {
          :id=>"compsci-61c-2014-C",
          :slug=>"compsci-61c",
          :course_code=>"COMPSCI 61C",
          :term_yr=>"2014",
          :term_cd=>"C",
          :dept=>"COMPSCI",
          :dept_desc=>"Computer Science",
          :catid=>"61C",
          :course_catalog=>"61C",
          :emitter=>"Campus",
          :name=>"Machine Structures",
          :sections=>[
            {:ccn=>"28730", :instruction_format=>"LEC", :is_primary_section=>true, :section_label=>"LEC 001", :section_number=>"001", :unit=>nil, :pnp_flag=>"N ", :cred_cd=>nil, :schedules=>[{:buildingName=>"LEWIS", :roomNumber=>"100", :schedule=>"MTuWTh 9:30A-11:00A"}], :instructors=>[{:name=>"Alfred Watson", :uid=>"875321"}]},
            {:ccn=>"28745", :instruction_format=>"DIS", :is_primary_section=>false, :section_label=>"DIS 102", :section_number=>"102", :schedules=>[{:buildingName=>"HEARST MIN", :roomNumber=>"310", :schedule=>"MW 2:00P-3:00P"}], :instructors=>[]},
            {:ccn=>"28750", :instruction_format=>"LAB", :is_primary_section=>false, :section_label=>"LAB 102", :section_number=>"102", :schedules=>[{:buildingName=>"SUTARDJA DAI", :roomNumber=>"200", :schedule=>"TuTh 1:00P-3:00P"}], :instructors=>[]}
          ],
          :role=>"Student"
        }
      ],
    }
  end

  subject           { Berkeley::CoursePolicy.new(user, course) }

  its(:user)        { should eq user }
  its(:record)      { should eq course }

  describe "#can_view_roster_photos?" do
    context "when user is an instructor in the course" do
      before do
        allow_any_instance_of(CampusOracle::UserCourses::All).to receive(:get_all_campus_courses).and_return(instructor_courses)
      end
      it "returns true" do
        expect(subject.can_view_roster_photos?).to be_truthy
      end
    end

    context "when user is not an instructor in the course" do
      before do
        allow_any_instance_of(CampusOracle::UserCourses::All).to receive(:get_all_campus_courses).and_return(student_courses)
      end
      it "returns false" do
        expect(subject.can_view_roster_photos?).to be_falsey
      end
    end

    context "when user is not associated with the course" do
      before do
        student_courses["2014-D"][0][:id] = "chem-1a-1994-B"
        allow_any_instance_of(CampusOracle::UserCourses::All).to receive(:get_all_campus_courses).and_return(student_courses)
      end
      it "returns false" do
        expect(subject.can_view_roster_photos?).to be_falsey
      end
    end

    context "when no courses associated with the user" do
      before do
        allow_any_instance_of(CampusOracle::UserCourses::All).to receive(:get_all_campus_courses).and_return({})
      end
      it "returns false" do
        expect(subject.can_view_roster_photos?).to be_falsey
      end
    end
  end

end
