require "spec_helper"

describe "Rosters::Campus" do
  let(:term_yr) {'2014'}
  let(:term_cd) {'B'}
  let(:user_id) {rand(99999).to_s}
  let(:student_user_id) {rand(99999).to_s}
  let(:ccn1) {rand(9999)}
  let(:ccn2) {rand(9999)}
  let(:enrolled_student_login_id) {rand(99999).to_s}
  let(:enrolled_student_student_id) {rand(99999).to_s}
  let(:waitlisted_student_login_id) {rand(99999).to_s}
  let(:waitlisted_student_student_id) {rand(99999).to_s}
  let(:catid) {"#{rand(999)}"}
  let(:campus_course_id) {"info-#{catid}-#{term_yr}-#{term_cd}"}
  let(:fake_campus) do
    {
      "#{term_yr}-#{term_cd}" => [{
        id: campus_course_id,
        term_yr: term_yr,
        term_cd: term_cd,
        catid: catid,
        dept: 'INFO',
        course_code: "INFO #{catid}",
        emitter: 'Campus',
        name: "Data Rules Everything Around Me",
        role: 'Instructor',
        sections: [{
          ccn: ccn1,
          section_label: 'LEC 001'
        },
        {
          ccn: ccn2,
          section_label: 'LAB 001'
        }]
      }]
    }
  end

  let(:fake_campus_student) do
    {
      "#{term_yr}-#{term_cd}" => [{
        id: campus_course_id,
        term_yr: term_yr,
        term_cd: term_cd,
        catid: catid,
        dept: 'INFO',
        course_code: "INFO #{catid}",
        emitter: 'Campus',
        name: "Fake Course Name",
        role: 'Student',
        sections: [{
          ccn: ccn1,
          section_label: 'LEC 001'
        }]
      }]
    }
  end

  let(:fake_students) do
    [
        {
            'ldap_uid' => enrolled_student_login_id,
            'enroll_status' => 'E',
            'student_id' => enrolled_student_student_id,
            'first_name' => 'First Name',
            'last_name' => 'Last Name'
        },
        {
            'ldap_uid' => waitlisted_student_login_id,
            'enroll_status' => 'W',
            'student_id' => waitlisted_student_student_id,
            'first_name' => 'First Name',
            'last_name' => 'Last Name'
        }
    ]
  end

  before do
    CampusOracle::UserCourses.stub(:new).with(user_id: user_id).and_return(double(get_all_campus_courses: fake_campus))
    CampusOracle::UserCourses.stub(:new).with(user_id: student_user_id).and_return(double(get_all_campus_courses: fake_campus_student))
    CampusOracle::Queries.stub(:get_enrolled_students).with(ccn1, term_yr, term_cd).and_return(fake_students)
    CampusOracle::Queries.stub(:get_enrolled_students).with(ccn2, term_yr, term_cd).and_return(fake_students)
  end

  it "should return a list of officially enrolled students for a course ccn" do

    model = Rosters::Campus.new(user_id, course_id: campus_course_id)
    feed = model.get_feed
    feed[:campus_course][:id].should == campus_course_id
    feed[:sections].length.should == 2
    feed[:sections][0][:name].should == "INFO #{catid} LEC 001"
    feed[:students].length.should == 2

    student = feed[:students][0]
    student[:id].should == enrolled_student_login_id
    student[:student_id].should == enrolled_student_student_id
    student[:first_name].blank?.should be_false
    student[:last_name].blank?.should be_false
    student[:sections].length.should == 2
    student[:profile_url].blank?.should be_false
  end

  it "should show official photo links for students who are not waitlisted in all sections" do

    model = Rosters::Campus.new(user_id, course_id: campus_course_id)
    feed = model.get_feed
    feed[:sections].length.should == 2
    feed[:students].length.should == 2
    feed[:students].index {|student| student[:id] == enrolled_student_login_id &&
        !student[:photo].end_with?(Rosters::Campus::PHOTO_UNAVAILABLE_FILENAME)
    }.should_not be_nil
    feed[:students].index {|student| student[:id] == waitlisted_student_login_id &&
        student[:photo].nil?
    }.should_not be_nil
  end

  it "should give access to only to course instructors" do
    model = Rosters::Campus.new(user_id, course_id: campus_course_id)
    model.user_authorized?.should be_true
    model = Rosters::Campus.new(student_user_id, course_id: campus_course_id)
    model.user_authorized?.should be_false
  end

end
