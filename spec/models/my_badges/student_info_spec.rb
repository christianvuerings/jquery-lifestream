require "spec_helper"

describe "MyBadges::StudentInfo" do

  let(:random_uid) { Time.now.to_f.to_s.gsub(".", "") }
  let(:default_name) { "David Hasselhoff "}
  let(:student_info_instance) { MyBadges::StudentInfo.new(random_uid) }
  let(:fake_courses_proxy) {    CampusOracle::UserCourses.new({:fake => true} ) }

  before(:each) do
    CampusOracle::UserAttributes.stub(:new).and_return(double(get_feed: {
      'person_name' => default_name,
      :roles => {
        :student => true,
        :exStudent => false,
        :faculty => false,
        :staff => false
      }
    }))
  end

  it "should create student_info instance along with the necessary variables" do
    u = MyBadges::StudentInfo.new(random_uid)
    u.should_not be_nil
    u.is_a?(MyBadges::StudentInfo).should be_true
  end

  it "should create a well-formed response with correct keys for a random user" do
    result = MyBadges::StudentInfo.new(random_uid).get
    result.has_key?(:californiaResidency).should be_true
    result.has_key?(:regStatus).should be_true
    result.has_key?(:regBlock).should be_true
  end

  it "should create camelCased regBlocks for oski" do
    result = MyBadges::StudentInfo.new('61889').get_reg_blocks
    result.has_key?(:needsAction).should be_true
    result.has_key?(:activeBlocks).should be_true
  end

  context "invalid/offline bearfacts regblock" do

    before { Bearfacts::Regblocks.any_instance.stub(:get).and_return {} }
    subject { MyBadges::StudentInfo.new("61889").get }

    it "should have no active blocks" do
      subject[:regBlock].should be_present
      subject[:regBlock][:activeBlocks].should be_present
      subject[:regBlock][:activeBlocks].should eq(0)
    end

    it "bearfacts API should be offline" do
      subject[:regBlock][:available].should be_false
    end

    it "needsAction should be false" do
      subject[:regBlock][:needsAction].should be_false
    end
  end

  context "valid bearfacts regblocks" do
    let! (:oski_blocks_proxy) { Bearfacts::Regblocks.new({:user_id => "61889", :fake => true}) }
    before do
      Bearfacts::Proxy.any_instance.stub(:lookup_student_id).and_return(11667051)
      Bearfacts::Regblocks.stub(:new).and_return(oski_blocks_proxy)
    end

    subject { MyBadges::StudentInfo.new("61889").get }

    it "should return some active_blocks" do
      subject[:regBlock].should be_present
      subject[:regBlock][:activeBlocks].should be_present
      subject[:regBlock][:activeBlocks].should > 0
    end

    it "bearfacts API should be online" do
      subject[:regBlock][:available].should be_true
    end

    it "needsAction should be true" do
      subject[:regBlock][:needsAction].should be_true
    end

  end
end
