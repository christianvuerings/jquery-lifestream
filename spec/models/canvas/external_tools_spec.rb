require "spec_helper"

describe Canvas::ExternalTools do

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
    it "should return a list with only id and name" do
      filtered_list = subject.public_list
      expect(filtered_list).to be_an_instance_of Hash
      filtered_list.each do |name, id|
        expect(name).to be_an_instance_of String
        expect(id).to be_an_instance_of Fixnum
      end
    end
    it 'includes a cached JSON endpoint for maximal efficiency' do
      expect(Rails.cache).to receive(:write).once
      raw_feed = subject.public_list
      json_feed = subject.public_list_as_json
      expect(json_feed).to eq raw_feed.to_json
    end
  end

end
