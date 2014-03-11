require "spec_helper"

describe CanvasCourseUsersProxy do

  let(:user_id)             { 4868640 }
  let(:canvas_course_id)    { 1164764 }
  subject                   { CanvasCourseUsersProxy.new(:user_id => user_id, :course_id => canvas_course_id) }

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
    CanvasCourseUsersProxy.should_receive(:fetch_from_cache).and_return([])
    users = subject.course_users
    expect(users).to be_an_instance_of Array
    expect(users.count).to eq 0
  end

  it "bypasses cache when cache option is false" do
    CanvasCourseUsersProxy.should_not_receive(:fetch_from_cache)
    users = subject.course_users(:cache => false)
    expect(users).to be_an_instance_of Array
    expect(users.count).to eq 6
  end

end
