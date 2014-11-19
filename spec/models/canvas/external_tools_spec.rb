require "spec_helper"

describe Canvas::ExternalTools do

  it "should use root canvas account by default" do
    account_id = subject.instance_eval { @canvas_account_id }
    expect(account_id).to eq Settings.canvas_proxy.account_id
  end

  it "supports alternative canvas account id" do
    account_id = Canvas::ExternalTools.new(:canvas_account_id => '1234').instance_eval { @canvas_account_id }
    expect(account_id).to eq '1234'
  end

  it "should return external tools list" do
    list = subject.external_tools_list
    expect(list).to be_an_instance_of Array
    expect(list.count).to eq 6
    expect(list[0]['id']).to eq 24486
    expect(list[0]['name']).to eq "Attendance Tool"
    expect(list[0]['url']).to eq "https://rollcall.instructure.com/launch"
    expect(list[0]['description']).to eq "A very handy tool for creating seating charts and keeping track of attendance."
    expect(list[0]['consumer_key']).to eq "xx"
    expect(list[0]['privacy_level']).to eq "public"
    expect(list[0]['workflow_state']).to eq "public"
    expect(list[0]['vendor_help_link']).to eq nil
    expect(list[0]['user_navigation']).to eq nil
    expect(list[0]['resource_selection']).to eq nil
    expect(list[0]['editor_button']).to eq nil
    expect(list[0]['homework_submission']).to eq nil
    expect(list[0]['course_navigation']).to be_an_instance_of Hash
    expect(list[0]['course_navigation']['url']).to eq "https://rollcall.instructure.com/launch"
    expect(list[0]['course_navigation']['text']).to eq "Attendance"
    expect(list[0]['course_navigation']['visibility']).to eq "admins"
    expect(list[0]['course_navigation']['label']).to eq "Attendance"
    expect(list[0]['course_navigation']['selection_width']).to eq 800
    expect(list[0]['course_navigation']['selection_height']).to eq 400
    expect(list[0]['account_navigation']).to be_an_instance_of Hash
    expect(list[0]['account_navigation']['url']).to eq "https://rollcall.instructure.com/launch"
    expect(list[0]['account_navigation']['text']).to eq "Attendance"
    expect(list[0]['account_navigation']['visibility']).to eq "admins"
    expect(list[0]['account_navigation']['label']).to eq "Attendance"
    expect(list[0]['account_navigation']['selection_width']).to eq 800
    expect(list[0]['account_navigation']['selection_height']).to eq 400
    expect(list[0]['updated_at']).to eq "2013-07-29T16:36:13Z"
    expect(list[0]['created_at']).to eq "2013-07-29T16:36:13Z"
  end

  context "when returning a public list of external tools" do
    let(:fake_global_apps) {[
      {'id' => 123, 'name' => 'Global App #1'},
      {'id' => 124, 'name' => 'Global App #2'}
    ]}
    let(:fake_official_apps) {[
      {'id' => 128, 'name' => 'Official Courses App #1'},
      {'id' => 129, 'name' => 'Official Courses App #2'}
    ]}
    let(:fake_global_apps_proxy) { double(:external_tools_list => fake_global_apps) }
    let(:fake_official_apps_proxy) { double(:external_tools_list => fake_official_apps) }

    it "should return global and official lists containing only id and name" do
      expect(Canvas::ExternalTools).to receive(:new).with(:canvas_account_id => Settings.canvas_proxy.account_id).and_return(fake_global_apps_proxy)
      expect(Canvas::ExternalTools).to receive(:new).with(:canvas_account_id => Settings.canvas_proxy.official_courses_account_id).and_return(fake_official_apps_proxy)
      filtered_list = Canvas::ExternalTools.public_list
      expect(filtered_list).to be_an_instance_of Hash
      expect(filtered_list.keys).to eq [:globalTools, :officialCourseTools]
      expect(filtered_list[:globalTools]['Global App #1']).to eq 123
      expect(filtered_list[:globalTools]['Global App #2']).to eq 124
      expect(filtered_list[:officialCourseTools]['Official Courses App #1']).to eq 128
      expect(filtered_list[:officialCourseTools]['Official Courses App #2']).to eq 129
    end

    it 'includes a cached JSON endpoint for maximal efficiency' do
      allow(Canvas::ExternalTools).to receive(:new).with(:canvas_account_id => Settings.canvas_proxy.account_id).and_return(fake_global_apps_proxy)
      allow(Canvas::ExternalTools).to receive(:new).with(:canvas_account_id => Settings.canvas_proxy.official_courses_account_id).and_return(fake_official_apps_proxy)
      expect(Rails.cache).to receive(:write).once
      raw_feed = Canvas::ExternalTools.public_list
      json_feed = Canvas::ExternalTools.public_list_as_json
      expect(json_feed).to eq raw_feed.to_json
    end
  end

end
