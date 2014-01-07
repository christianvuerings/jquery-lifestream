require "spec_helper"

describe MyActivities::Notifications do
  let!(:oski_uid) { "61889" }
  let(:documented_types) { %w(alert) }
  before(:each) do
    CampusData.stub(:get_reg_status).and_return({
      "ldap_uid" => oski_uid,
      "reg_status_cd" => "C"
    })
    MyActivities::Merged.stub(:cutoff_date).and_return(Time.at(0).to_i)
    bootstrap_notification
  end

  # Should just stub out Notification.where instead of this roundabout way of doing things...
  def bootstrap_notification
    UserApi.new(oski_uid).record_first_login
    event = JSON.parse('{"topic":"Bearfacts:RegStatus","timestamp":"2013-05-30T07:15:09.191-07:00","payload":{"uid":[61889,300847]}}')
    raise RuntimeError, 'process should be true' unless RegStatusEventProcessor.new().process(event, Time.now.to_datetime)
  end

  it { described_class.should respond_to(:append!) }

  context "should successfully handle well translated responses from notifications" do
    subject do
      activities = []
      described_class.append!(oski_uid, activities)
      activities
    end

    it { should_not be_empty }
    it "should contain some Bearfacts notifications" do
      regstatus_items = subject.select {|notification| notification[:source] == 'Bear Facts'}
      regstatus_items.should_not be_empty
    end
    it { subject.each {|notification| documented_types.include?(notification[:type]).should be_true }}
  end

  context "should successfully handle badly translated responses from notifications" do
    before(:each) { RegStatusTranslator.any_instance.stub(:translate).and_return false }

    subject do
      activities = []
      described_class.append!(oski_uid, activities)
      activities
    end

    it {
      Notification.find_by_uid(oski_uid).should_not be_blank
      should be_empty
    }
  end
end
