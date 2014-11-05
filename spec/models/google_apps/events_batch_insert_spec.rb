require "spec_helper"

describe GoogleApps::EventsBatchInsert do
  let(:user_id) { rand(999999).to_s }
  # be careful about modifying payloads, the proxies are matching vcr recordings
  # also by body since these are POSTs
  let!(:valid_payload) do
    {
      'calendarId' => 'primary',
      'summary' => 'Fancy event',
      'start' => {
        'dateTime' => '2013-09-24T02:06:00.000-07:00'
      },
      'end' => {
        'dateTime' => '2013-09-24T03:06:00.000-07:00'
      }
    }
  end
  let(:invalid_payload) do
    {
      'calendarId' => 'primary',
      'summary' => 'Fancy event',
      'start' => {
        'dateTime' => '2013-09-24T02:06:00.000-07:00'
      },
      'end' => {
        'dateTime' => '2013-09-24T03:06:00.000-07:0'
      }
    }
  end

  shared_examples "200 insert event task" do
    its(:status) { should eq(200) }
    it { subject.data["summary"].should eq("Fancy event")}
    it { subject.data["status"].should eq("confirmed") }
  end

  shared_examples "4xx insert event task" do
    its(:status) { should eq(400) }
    it { subject.data.should_not be_blank }
    it { subject.data.error.should_not be_blank }
  end

  context "fake insert event test", ignore: true do #  if: Rails.env.test? do
    before(:each) do
      fake_proxy = GoogleApps::EventsBatchInsert.new(fake: true)
      GoogleApps::EventsBatchInsert.stub(:new).and_return(fake_proxy)
    end

    context "valid payload" do
      subject { GoogleApps::EventsBatchInsert.new(user_id).insert_event(valid_payload) }
      it_behaves_like "200 insert event task"
    end

    context "invalid payload" do
      subject { GoogleApps::EventsBatchInsert.new(user_id).insert_event(invalid_payload) }
      it_behaves_like "4xx insert event task"
    end
  end

  context "real insert event test" do # , testext: true do
    before(:each) do
      token_info = {
        access_token: Settings.google_proxy.test_user_access_token,
        refresh_token: Settings.google_proxy.test_user_refresh_token,
        expiration_time: 0
      }
      real_insert_proxy = GoogleApps::EventsBatchInsert.new(token_info)
      real_delete_proxy = GoogleApps::EventsBatchDelete.new(token_info)
      GoogleApps::EventsBatchInsert.stub(:new).and_return(real_insert_proxy)
      GoogleApps::EventsBatchDelete.stub(:new).and_return(real_delete_proxy)
    end

    context "invalid payload" do
      subject { GoogleApps::EventsBatchInsert.new(user_id).insert_event(invalid_payload) }
      it_behaves_like "4xx insert event task"
    end

    context "valid payload" do
      let(:delete_proxy) { GoogleApps::EventsBatchDelete.new(user_id) }
      subject { @insert_response = GoogleApps::EventsBatchInsert.new(user_id).insert_event(valid_payload) }
      after(:each) do
        insert_id = @insert_response.data["id"]
        delete_proxy.delete_event(insert_id)
      end

      it_behaves_like "200 insert event task"
    end

  end
end
