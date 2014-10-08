require "spec_helper"

describe MyActivities::SakaiAnnouncements, :if => Sakai::SakaiData.test_data? do
  let!(:fake_uid) { Settings.sakai_proxy.fake_user_id }
  let!(:fake_sites) { MyActivities::DashboardSites.fetch(fake_uid, {fake: true}) }
  let(:documented_types) { %w(announcement) }

  subject do
    activities = []
    described_class.append!(fake_uid, fake_sites, activities)
    activities
  end

  it { described_class.should respond_to(:append!) }
  it { should_not be_empty }
  it "announcements should be properly formatted" do
    subject.each do |act|
      act[:emitter].should == 'bSpace'
      act[:type].should == 'announcement'
      act[:source].blank?.should be_falsey
    end
  end
end
