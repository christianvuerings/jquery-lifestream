require "spec_helper"

describe Canvas::CourseUsers do

  let(:user_id)             { 4868640 }
  let(:canvas_course_id)    { 1164764 }
  subject                   { Canvas::CourseUsers.new(:user_id => user_id, :course_id => canvas_course_id) }

  it "provides course users" do
    users = subject.course_users
    expect(users).to be_an_instance_of Array
    expect(users.count).to eq 6
    expect(users[0]['id']).to eq 4862319
    expect(users[0]['name']).to eq "Ted Andrew Greenwald"
    expect(users[0]['sis_user_id']).to eq "UID:4000123"
    expect(users[0]['sis_login_id']).to eq "4000123"
    expect(users[0]['login_id']).to eq "4000123"
    expect(users[0]['enrollments']).to be_an_instance_of Array
    expect(users[0]['enrollments'].count).to eq 1
    expect(users[0]['enrollments'][0]['course_id']).to eq 1164764
    expect(users[0]['enrollments'][0]['course_section_id']).to eq 1312012
    expect(users[0]['enrollments'][0]['id']).to eq 20187382
    expect(users[0]['enrollments'][0]['type']).to eq "StudentEnrollment"
    expect(users[0]['enrollments'][0]['role']).to eq "StudentEnrollment"
  end

  it "uses cache by default" do
    expect(Canvas::CourseUsers).to receive(:fetch_from_cache).and_return([])
    users = subject.course_users
    expect(users).to be_an_instance_of Array
    expect(users.count).to eq 0
  end

  it "bypasses cache when cache option is false" do
    expect(Canvas::CourseUsers).to_not receive(:fetch_from_cache)
    users = subject.course_users(:cache => false)
    expect(users).to be_an_instance_of Array
    expect(users.count).to eq 6
  end

  context "when providing course user grades" do
    it "returns information relevant to egrades csv export" do
      course_user_grades_csv_string = subject.course_grades_csv
      expect(course_user_grades_csv_string).to be_an_instance_of String
      course_user_grades_csv = CSV.parse(course_user_grades_csv_string, {headers: true})
      expect(course_user_grades_csv.count).to eq 6
      course_user_grades_csv.each do |user_grade|
        expect(user_grade).to be_an_instance_of CSV::Row
        expect(user_grade['uid']).to be_an_instance_of String
        expect(user_grade['grade']).to be_an_instance_of String
        expect(user_grade['comment']).to be_an_instance_of String
      end
      expect(course_user_grades_csv[0]['uid']).to eq "4000123"
      expect(course_user_grades_csv[0]['grade']).to eq "34.9"
      expect(course_user_grades_csv[0]['comment']).to eq ""

      expect(course_user_grades_csv[5]['uid']).to eq "4000272"
      expect(course_user_grades_csv[5]['grade']).to eq "10.5"
      expect(course_user_grades_csv[5]['comment']).to eq ""
    end

    it "should not source data from cache" do
      expect(Canvas::CourseUsers).to_not receive(:fetch_from_cache)
      course_user_grades_csv = subject.course_grades_csv
    end
  end

end
