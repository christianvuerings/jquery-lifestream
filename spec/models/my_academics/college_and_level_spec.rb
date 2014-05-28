require "spec_helper"

describe "MyAcademics::CollegeAndLevel" do

  it "should get properly formatted data from fake Bearfacts" do
    oski_profile_proxy = Bearfacts::Profile.new({:user_id => "61889", :fake => true})
    Bearfacts::Profile.stub(:new).and_return(oski_profile_proxy)

    feed = {}
    MyAcademics::CollegeAndLevel.new("61889").merge(feed)
    feed.empty?.should be_false

    oski_college = feed[:college_and_level]
    oski_college.should_not be_nil
    oski_college[:colleges].size.should == 3
    oski_college[:colleges][0][:college].should == "College of Engineering"
    oski_college[:colleges][1][:college].should == ""
    oski_college[:colleges][2][:college].should == ""
    oski_college[:colleges][0][:major].should == "Economics"
    oski_college[:colleges][1][:major].should == "Rhetoric"
    oski_college[:colleges][2][:major].should == "Business Administration"
    oski_college[:standing].should == "Undergraduate"
  end

  it "should get test-300940's multiple college enrollments" do
    tammi_proxy = Bearfacts::Profile.new({:user_id => "300940", :fake => true})
    Bearfacts::Profile.stub(:new).and_return(tammi_proxy)

    feed = {}
    MyAcademics::CollegeAndLevel.new("300940").merge(feed)
    feed.empty?.should be_false

    colleges = feed[:college_and_level][:colleges]
    colleges.size.should == 2
    colleges[0][:college].should == "College of Natural Resources"
    colleges[0][:major].should == "Conservation And Resource Studies"
    colleges[1][:college].should == "College of Environmental Design"
    colleges[1][:major].should == "Landscape Architecture"

  end

  it "should get get a concurrent enrollment triple major's multiple college enrollments" do
    triple_proxy = Bearfacts::Profile.new({:user_id => "212379", :fake => true})
    Bearfacts::Profile.stub(:new).and_return(triple_proxy)

    feed = {}
    MyAcademics::CollegeAndLevel.new("212379").merge(feed)
    feed.empty?.should be_false

    colleges = feed[:college_and_level][:colleges]
    colleges.size.should == 3
    colleges[0][:college].should == "College of Chemistry"
    colleges[0][:major].should == "Chemistry"
    colleges[1][:college].should == "College of Letters & Science"
    colleges[1][:major].should == "Applied Mathematics"
    colleges[2][:college].should == ""
    colleges[2][:major].should == "Physics"
  end

  it "should get a double Law major correctly" do
    double_proxy = Bearfacts::Profile.new({:user_id => "212381", :fake => true})
    Bearfacts::Profile.stub(:new).and_return(double_proxy)

    feed = {}
    MyAcademics::CollegeAndLevel.new("212381").merge(feed)
    feed.empty?.should be_false

    colleges = feed[:college_and_level][:colleges]
    colleges.size.should == 2
    colleges[0][:college].should == "School of Law"
    colleges[0][:major].should == "Jurisprudence And Social Policy"
    colleges[1][:college].should == ""
    colleges[1][:major].should == "Law"
  end

  context "failing bearfacts proxy" do
    before(:each) do
      stub_request(:any, /#{Regexp.quote(Settings.bearfacts_proxy.base_url)}.*/).to_raise(Errno::EHOSTUNREACH)
      Bearfacts::Profile.new({:user_id => "212381", :fake => false})
    end
    after(:each) { WebMock.reset! }

    subject do
      MyAcademics::CollegeAndLevel.new("212381").merge(@feed = {})
      @feed
    end

    it { should be_blank }
  end

  context 'when Bearfacts feed is incomplete' do
    let(:uid) {rand(999999)}
    let(:feed) {{}}
    before do
      allow(Bearfacts::Profile).to receive(:new).with(user_id: uid).and_return(double(get: {status_code: 204, body: xml_body}))
    end
    subject do
      MyAcademics::CollegeAndLevel.new(uid).merge(feed)
      feed
    end
    context 'when ex-student with empty BearFacts student profile' do
      let(:xml_body) {nil}
      it {should be_blank}
    end
    context 'when Bearfacts student profile lacks key data' do
      let(:xml_body) {
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<studentProfile xmlns=\"urn:berkeley.edu/babl\" termName=\"Spring\" termYear=\"2014\" asOfDate=\"May 27, 2014 12:00 AM\"><studentType>STUDENT</studentType><noProfileDataFlag>false</noProfileDataFlag><studentGeneralProfile><studentName><firstName>OWPRQTOPEW</firstName><middleName></middleName><middleInitial></middleInitial><lastName>SEBIRTFEIWB</lastName></studentName></studentGeneralProfile></studentProfile>"
      }
      it {should be_blank}
    end
  end

end
