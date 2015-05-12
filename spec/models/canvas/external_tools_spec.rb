describe Canvas::ExternalTools do

  describe 'api_root' do
    subject { Canvas::ExternalTools.new(options).instance_eval { @api_root } }
    context 'default' do
      let(:options) { {} }
      it 'uses the root Canvas canvas account' do
        is_expected.to eq "accounts/#{Settings.canvas_proxy.account_id}"
      end
    end
    context 'specifying an account' do
      let(:options) { {canvas_account_id: '123456'} }
      it { is_expected.to eq 'accounts/123456' }
    end
    context 'specifying a course site' do
      let(:options) { {canvas_course_id: '98765'} }
      it { is_expected.to eq 'courses/98765' }
    end
  end

  it 'should return external tools list' do
    list = subject.external_tools_list
    expect(list).to be_an_instance_of Array
    expect(list).to have(5).items
    expect(list[0]['id']).to eq 24486
    expect(list[0]['name']).to eq 'Attendance Tool'
    expect(list[0]['url']).to eq 'https://rollcall.instructure.com/launch'
    expect(list[0]['description']).to eq 'A very handy tool for creating seating charts and keeping track of attendance.'
    expect(list[0]['consumer_key']).to eq 'xx'
    expect(list[0]['privacy_level']).to eq 'public'
    expect(list[0]['workflow_state']).to eq 'public'
    expect(list[0]['vendor_help_link']).to eq nil
    expect(list[0]['user_navigation']).to eq nil
    expect(list[0]['resource_selection']).to eq nil
    expect(list[0]['editor_button']).to eq nil
    expect(list[0]['homework_submission']).to eq nil
    expect(list[0]['course_navigation']).to be_an_instance_of Hash
    expect(list[0]['course_navigation']['url']).to eq 'https://rollcall.instructure.com/launch'
    expect(list[0]['course_navigation']['text']).to eq 'Attendance'
    expect(list[0]['course_navigation']['visibility']).to eq 'admins'
    expect(list[0]['course_navigation']['label']).to eq 'Attendance'
    expect(list[0]['course_navigation']['selection_width']).to eq 800
    expect(list[0]['course_navigation']['selection_height']).to eq 400
    expect(list[0]['account_navigation']).to be_an_instance_of Hash
    expect(list[0]['account_navigation']['url']).to eq 'https://rollcall.instructure.com/launch'
    expect(list[0]['account_navigation']['text']).to eq 'Attendance'
    expect(list[0]['account_navigation']['visibility']).to eq 'admins'
    expect(list[0]['account_navigation']['label']).to eq 'Attendance'
    expect(list[0]['account_navigation']['selection_width']).to eq 800
    expect(list[0]['account_navigation']['selection_height']).to eq 400
    expect(list[0]['updated_at']).to eq '2013-07-29T16:36:13Z'
    expect(list[0]['created_at']).to eq '2013-07-29T16:36:13Z'
  end

  describe '#tabs_api' do
    subject { Canvas::ExternalTools.new options }

    context 'when modifying tab settings per canvas_course_id' do
      let(:tab_id) { 'my_tab_external_tool_4' }
      let(:canvas_course_id) { 98765 }
      let(:options) { {canvas_course_id: "#{canvas_course_id}"} }
      let(:api_path) { "courses/#{canvas_course_id}/tabs/#{tab_id}" }
      let(:vcr_id) { '_update_course_site_tab_hidden' }
      let(:tab_showing) {
        {
          'html_url' => '/courses/1/external_tools/4',
          'id' => "#{tab_id}",
          'label' => 'My Tab',
          'type' => 'external',
          'visibility' => 'public',
          'position' => 2
        }
      }
      let(:tab_hidden) { tab_showing.merge({ 'hidden' => true }) }
      let(:tab_hidden_response) { double(status: 200, body: tab_hidden.to_json) }
      let(:tab_showing_response) { double(status: 200, body: tab_showing.to_json) }

      it 'should return tab with hidden=true' do
        expect(subject).to receive(:request_uncached).with(api_path, vcr_id, anything).and_return tab_hidden_response
        expect(subject.hide_course_site_tab tab_id).to eq tab_hidden
      end

      it 'should return tab with no hidden attribute' do
        expect(subject).to receive(:request_uncached).with(api_path, vcr_id, anything).and_return tab_showing_response
        expect(subject.show_course_site_tab tab_id).to eq tab_showing
      end
    end
  end

  context 'when returning a public list of external tools' do
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

    it 'should return global and official lists containing only id and name' do
      expect(Canvas::ExternalTools).to receive(:new).with(:canvas_account_id => Settings.canvas_proxy.account_id).and_return fake_global_apps_proxy
      expect(Canvas::ExternalTools).to receive(:new).with(:canvas_account_id => Settings.canvas_proxy.official_courses_account_id).and_return fake_official_apps_proxy
      filtered_list = Canvas::ExternalTools.public_list
      expect(filtered_list).to be_an_instance_of Hash
      expect(filtered_list.keys).to eq [:globalTools, :officialCourseTools]
      expect(filtered_list[:globalTools]['Global App #1']).to eq 123
      expect(filtered_list[:globalTools]['Global App #2']).to eq 124
      expect(filtered_list[:officialCourseTools]['Official Courses App #1']).to eq 128
      expect(filtered_list[:officialCourseTools]['Official Courses App #2']).to eq 129
    end

    it 'includes a cached JSON endpoint for maximal efficiency' do
      allow(Canvas::ExternalTools).to receive(:new).with(:canvas_account_id => Settings.canvas_proxy.account_id).and_return fake_global_apps_proxy
      allow(Canvas::ExternalTools).to receive(:new).with(:canvas_account_id => Settings.canvas_proxy.official_courses_account_id).and_return fake_official_apps_proxy
      expect(Rails.cache).to receive(:write).once
      raw_feed = Canvas::ExternalTools.public_list
      json_feed = Canvas::ExternalTools.public_list_as_json
      expect(json_feed).to eq raw_feed.to_json
    end
  end

end
