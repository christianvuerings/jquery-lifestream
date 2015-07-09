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
      let(:canvas_course_id) { 98765 }
      let(:options) { {canvas_course_id: "#{canvas_course_id}"} }
      let(:tab_showing) { create_tab(canvas_course_id, 'tab_showing_1') }
      let(:tab_hidden) { create_tab(canvas_course_id, 'tab_hidden_2', {'hidden' => 'true'}) }
      let(:untargeted_tab) { create_tab(canvas_course_id, 'untargeted_tab_3', {'hidden' => 'true'}) }
      let(:all_tabs) { [tab_showing, tab_hidden, untargeted_tab] }
      let(:all_tabs_url) { "courses/#{canvas_course_id}/tabs" }

      it 'should return tab with hidden equals true' do
        all_tabs_response = double(status: 200, body: all_tabs.to_json)
        expect(subject).to receive(:request_uncached).with(all_tabs_url, '_course_site_tab_list', anything).twice.and_return all_tabs_response
        tab_id = tab_showing['id']
        url = "courses/#{canvas_course_id}/tabs/#{tab_id}"
        hidden_after_update = create_tab(canvas_course_id, tab_id, {'hidden' => 'true'})
        update_response = double(status: 200, body: hidden_after_update.to_json)
        expect(subject).to receive(:request_uncached).with(url, '_update_course_site_tab', expected_options(tab_id, true)).and_return update_response
        result = subject.hide_course_site_tab tab_showing
        expect(result.to_json).to eq update_response.body
      end

      it 'should fix collateral damage when untargeted tabs are updated' do
        all_tabs_response = double(status: 200, body: all_tabs.to_json)
        # Expect snapshot of tabs before update
        expect(subject).to receive(:request_uncached).with(all_tabs_url, '_course_site_tab_list', anything).once.and_return all_tabs_response
        # Expect standard update
        target_tab_id = tab_hidden['id']
        update_tab_response = double(status: 200, body: create_tab(canvas_course_id, target_tab_id).to_json)
        update_tab_url = "courses/#{canvas_course_id}/tabs/#{target_tab_id}"
        expect(subject).to receive(:request_uncached).with(update_tab_url, '_update_course_site_tab', expected_options(target_tab_id, false)).once.and_return update_tab_response
        # Expect update to untargeted tab
        untargeted_id = untargeted_tab['id']
        collateral_damage =  create_tab(canvas_course_id, untargeted_id)
        all_tabs_after_update = double(status: 200, body: [tab_showing, tab_hidden, collateral_damage].to_json)
        expect(subject).to receive(:request_uncached).with(all_tabs_url, '_course_site_tab_list', anything).once.and_return all_tabs_after_update
        # Expect restoration of untargeted tab
        fixed_tab = untargeted_tab.merge({'hidden' => true})
        untargeted_tab_updated = double(status: 200, body: fixed_tab.to_json)
        url = "courses/#{canvas_course_id}/tabs/#{untargeted_id}"
        expect(subject).to receive(:request_uncached).with(url, '_update_course_site_tab', expected_options(untargeted_id, true)).once.and_return untargeted_tab_updated
        # Now test
        result = subject.show_course_site_tab tab_hidden
        tab_now_showing = create_tab(canvas_course_id, target_tab_id)
        expect(result).to eq tab_now_showing
      end
    end

    def create_tab(canvas_course_id, tab_id, options = {})
      {
        'html_url' => "/courses/#{canvas_course_id}/external_tools/#{tab_id}",
        'id' => "#{tab_id}",
        'label' => "Tab #{tab_id}",
        'position' => tab_id,
        'visibility' => 'public'
      }.merge options
    end

    def expected_options(tab_id, expect_set_to_hidden)
      {
        :method => :put,
        :body => {
          'id' => tab_id,
          'hidden' => expect_set_to_hidden,
          'position' => tab_id,
          'visibility' => 'public'
        }
      }
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
