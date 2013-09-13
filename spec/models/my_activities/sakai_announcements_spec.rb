require "spec_helper"

describe MyActivities::SakaiAnnouncements, :if => SakaiData.test_data? do
  let!(:oski_uid) { "61889" }
  let!(:fake_sakai_user_sites) { SakaiUserSitesProxy.new(fake: true) }
  let(:documented_types) { %w(announcement) }

  before(:each) do
    SakaiProxy.stub(:access_granted?).and_return(true)
    SakaiUserSitesProxy.stub(:new).and_return(fake_sakai_user_sites)
  end

  subject do
    activities = []
    described_class.append!(oski_uid, activities)
    activities
  end

  it { described_class.should respond_to(:append!) }
  it { should_not be_empty }
  it "annoucements should be properly formatted" do
    subject.each do |act|
      act[:emitter].should == 'bSpace'
      act[:type].should == 'announcement'
      act[:source].blank?.should be_false
    end
  end
end