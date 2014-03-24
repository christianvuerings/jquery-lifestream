require "spec_helper"

describe Canvas::UserCourses do

  context 'working against test data' do
    subject {Canvas::UserCourses.new(fake: true).courses}
    its(:size) {should eq 2}
  end

  it "should get courses as known student" do
    courses = Canvas::UserCourses.new(:user_id => @user_id).courses
    courses.size.should > 0
    courses[0]['course_code'].should_not be_nil
    courses[0]['term'].should_not be_nil
    courses[0]['term']['name'].should_not be_nil
  end

  it "should return empty array if server is not available" do
    client = Canvas::UserCourses.new(user_id: @user_id, fake: false)
    stub_request(:any, /#{Regexp.quote(Settings.canvas_proxy.url_root)}.*/).to_raise(Faraday::Error::ConnectionFailed)
    suppress_rails_logging {
      response = client.courses
      response.should eq []
    }
    WebMock.reset!
  end

  it "should return empty array if server returns error status" do
    client = Canvas::UserCourses.new(user_id: @user_id, fake: false)
    stub_request(:any, /#{Regexp.quote(Settings.canvas_proxy.url_root)}.*/).to_return(
      status: 503,
      body: '<?xml version="1.0" encoding="ISO-8859-1"?>'
    )
    suppress_rails_logging {
      response = client.courses
      response.should eq []
    }
    WebMock.reset!
  end


end
