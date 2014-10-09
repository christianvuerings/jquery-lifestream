require "spec_helper"

describe Canvas::Proxy do

  before do
    @user_id = Settings.canvas_proxy.test_user_id
    @client = Canvas::Proxy.new(:user_id => @user_id)
  end

  context "when converting sis section ids to term and ccn" do
    it "should return term and ccn" do
      result = subject.class.sis_section_id_to_ccn_and_term("SEC:2014-B-25573")
      result.should be_an_instance_of Hash
      expect(result[:term_yr]).to eq '2014'
      expect(result[:term_cd]).to eq 'B'
      expect(result[:ccn]).to eq '25573'
    end
    it 'is not confused by leading zeroes' do
      result_plain = subject.class.sis_section_id_to_ccn_and_term('SEC:2014-B-1234')
      result_fancy = subject.class.sis_section_id_to_ccn_and_term('SEC:2014-B-01234')
      expect(result_fancy).to eq result_plain
    end
  end

  it "should see an account list as admin" do
    admin_client = Canvas::Proxy.new
    response = admin_client.request('accounts', '_admin')
    accounts = JSON.parse(response.body)
    accounts.size.should > 0
  end

  it "should see the same account list as admin, initiating Canvas::Proxy with a passed in token" do
    admin_client = Canvas::Proxy.new(:access_token => Settings.canvas_proxy.admin_access_token)
    response = admin_client.request('accounts', '_admin')
    accounts = JSON.parse(response.body)
    accounts.size.should > 0
  end

  it "should get own profile as authorized user", :testext => true do
    response = @client.request('users/self/profile', '_admin')
    profile = JSON.parse(response.body)
    profile['login_id'].should == @user_id.to_s
  end

  it "should get the upcoming_events feed for a known user", :testext => true do
    client = Canvas::UpcomingEvents.new(:user_id => @user_id)
    response = client.upcoming_events
    events = JSON.parse(response.body)
    events.should_not be_nil
    if events.length > 0
      events[0]["title"].should_not be_nil
      events[0]["html_url"].should_not be_nil
    end
  end

  it "should get the todo feed for a known user", :testext => true do
    client = Canvas::Todo.new(:user_id => @user_id)
    response = client.todo
    tasks = JSON.parse(response.body)
    tasks[0]["assignment"]["name"].should_not be_nil
    tasks[0]["assignment"]["course_id"].should_not be_nil
  end

  it "should get user activity feed using the Tammi account" do
    begin
      proxy = Canvas::UserActivityStream.new(:fake => true)
      response = proxy.user_activity
      user_activity = JSON.parse(response.body)
      user_activity.kind_of?(Array).should be_truthy
      user_activity.size.should == 20
      required_fields = %w(created_at updated_at id type html_url)
      user_activity.each do |entry|
        (entry.keys & required_fields).size.should == required_fields.size
        expect {
          DateTime.parse(entry["created_at"]) unless entry["created_at"].blank?
          DateTime.parse(entry["updated_at"]) unless entry["update_at"].blank?
        }.to_not raise_error
        entry["id"].is_a?(Integer).should == true
        category_specific_id_exists = entry["course_id"] || entry["group_id"] || entry["conversation_id"]
        category_specific_id_exists.blank?.should_not be_truthy
      end
    ensure
      VCR.eject_cassette
    end
  end

  it "should fetch all course students even if the Canvas feed is paged" do
    # The VCR recording has been edited to have four pages of results, only one student per page.
    proxy = Canvas::CourseStudents.new(course_id: 767330, fake: true)
    students = proxy.full_students_list
    students.length.should == 4
  end

  it "should find a registered user's profile" do
    client = Canvas::SisUserProfile.new(:user_id => @user_id)
    response = client.sis_user_profile
    response.should_not be_nil
  end

  it "should get Sections for any known Course" do
    client = Canvas::UserCourses.new(user_id: @user_id)
    courses = client.courses
    courses.each do |course|
      sections_proxy = Canvas::CourseSections.new(course_id: course['id'])
      sections_response = sections_proxy.sections_list
      sections = JSON.parse(sections_response.body)
      sections.should_not be_nil
      sections.each do |section|
        section['id'].blank?.should be_falsey
      end
    end
  end

  describe '#canvas_current_terms' do
    before { allow(Settings.terms).to receive(:fake_now).and_return(fake_now) }
    subject {Canvas::Proxy.canvas_current_terms}
    context 'during the Fall term' do
      let(:fake_now) {DateTime.parse('2013-10-10')}
      its(:length) {should eq 2}
      it 'includes next term and this term' do
        expect(subject[0].slug).to eq 'spring-2014'
        expect(subject[1].slug).to eq 'fall-2013'
      end
    end
    context 'between terms' do
      let(:fake_now) {DateTime.parse('2013-09-20')}
      its(:length) {should eq 2}
      it 'includes the next two terms' do
        expect(subject[0].slug).to eq 'spring-2014'
        expect(subject[1].slug).to eq 'fall-2013'
      end
    end
    context 'during the Spring term' do
      let(:fake_now) {DateTime.parse('2014-02-10')}
      its(:length) {should eq 3}
      it 'includes next Fall term if available' do
        expect(subject[0].slug).to eq 'fall-2014'
        expect(subject[1].slug).to eq 'summer-2014'
        expect(subject[2].slug).to eq 'spring-2014'
      end
    end
  end

end
