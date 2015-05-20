describe Canvas::ReconfigureExternalApps do
  let(:fake_canvas_host) {'https://ucberkeley.beta.instructure.com'}
  let(:fake_calcentral_host) {'cc-dev.example.com'}
  let(:reachable_xml_host) {'http://example.com'}
  let(:fake_external_tools_proxy) {Canvas::ExternalTools.new(fake: true)}
  let(:fake_reset_response) {double(nil, status: 200, body: {}.to_json)}

  describe '#reset_external_app_hosts_by_url' do
    context 'when servers need resetting' do
      let(:new_calcentral_host) {'jabberwock.example.com'}
      it 'resets all hosted apps' do
        fake_external_tools_list = fake_external_tools_proxy.external_tools_list
        external_tools_proxy = double()
        external_tools_proxy.should_receive(:external_tools_list).exactly(2).times.and_return(fake_external_tools_list)
        external_tools_proxy.should_receive(:reset_external_tool_config_by_url).exactly(6).times.and_return(fake_reset_response)
        Canvas::ExternalTools.stub(:new).with({url_root: fake_canvas_host, canvas_account_id: '90242'}).and_return(external_tools_proxy)
        Canvas::ExternalTools.stub(:new).with({url_root: fake_canvas_host, canvas_account_id: '129410'}).and_return(external_tools_proxy)
        subject.reset_external_app_hosts_by_url(reachable_xml_host, [
            {host: fake_canvas_host, calcentral: new_calcentral_host}
          ])
      end
    end

    context 'when servers are already up to date' do
      it 'leaves hosted apps alone' do
        fake_external_tools_list = fake_external_tools_proxy.external_tools_list
        external_tools_proxy = double()
        external_tools_proxy.should_receive(:external_tools_list).twice.and_return(fake_external_tools_list)
        external_tools_proxy.should_not_receive(:reset_external_tool_config_by_url)
        Canvas::ExternalTools.stub(:new).with({url_root: fake_canvas_host, canvas_account_id: '90242'}).and_return(external_tools_proxy)
        Canvas::ExternalTools.stub(:new).with({url_root: fake_canvas_host, canvas_account_id: '129410'}).and_return(external_tools_proxy)
        subject.reset_external_app_hosts_by_url(reachable_xml_host, [
            {host: fake_canvas_host, calcentral: fake_calcentral_host}
          ])
      end
    end
  end

  describe '#refresh_accounts' do
    it 'returns primary account as well as other lti accounts' do
      accounts = subject.refresh_accounts
      expect(accounts).to be_an_instance_of Array
      expect(accounts[0]).to eq Settings.canvas_proxy.account_id
      expect(accounts[1]).to eq Settings.canvas_proxy.official_courses_account_id
    end
  end

  describe '#configure_external_app_by_xml' do
    let(:fake_proxy) {instance_double(Canvas::ExternalTools)}
    let(:app_host) {"http://localhost:#{random_id}"}
    let(:app_code) {'rosters'}
    let(:app_id) {random_id}
    let(:configuration_result) do
      {
        app_id: app_id,
        status: expected_action
      }
    end
    let(:external_tool_configs) do
      [{
        'id' => app_id,
        'name' => 'Funhouse Fotos',
        'url' => "#{app_host}/canvas/embedded/#{app_code}"
      }]
    end
    before do
      allow(Canvas::ExternalTools).to receive(:new).with({canvas_account_id: Settings.canvas_proxy.official_courses_account_id}).and_return(fake_proxy)
      allow(fake_proxy).to receive(:external_tools_list).and_return(external_tool_configs)
    end

    subject { Canvas::ReconfigureExternalApps.new.configure_external_app_by_xml(app_host, app_code) }

    context 'the app is already in the Canvas account' do
      let(:expected_action) {'overwritten'}
      it 'fully reconfigures the app' do
        expect(fake_proxy).to receive(:reset_external_tool_by_xml) do |the_app_id, the_xml|
          expect(the_app_id).to eq app_id
          config = MultiXml.parse(the_xml)['cartridge_basiclti_link']
          expect(config['title']).to eq 'Roster Photos'
          expect(config['launch_url']).to eq external_tool_configs[0]['url']
          {
            'id' => app_id
          }
        end
        is_expected.to eq configuration_result
      end
    end
    context 'the app is not yet in the Canvas account' do
      let(:expected_action) {'added'}
      let(:external_tool_configs) {[]}
      it 'adds the app configuration' do
        expect(fake_proxy).to receive(:create_external_tool_by_xml) do |the_app_name, the_xml|
          expect(the_app_name).to eq 'Roster Photos'
          config = MultiXml.parse(the_xml)['cartridge_basiclti_link']
          expect(config['title']).to eq 'Roster Photos'
          expect(config['launch_url']).to eq "#{app_host}/canvas/embedded/#{app_code}"
          {
            'id' => app_id
          }
        end
        is_expected.to eq configuration_result
      end
    end
    context 'Canvas throws an error' do
      let(:expected_action) {'error'}
      it 'confesses failure' do
        expect(fake_proxy).to receive(:reset_external_tool_by_xml).and_return(nil)
        is_expected.to eq configuration_result
      end
    end
    context 'unknown app' do
      let(:app_code) {"#{random_id}thNervousBreakdown"}
      let(:configuration_result) do
        {
          status: 'unknown'
        }
      end
      it 'expresses confusion' do
        is_expected.to eq configuration_result
      end
    end
  end

  describe '#configure_all_apps_from_current_host' do
    let(:unknown_tool_id) {random_id}
    let(:webcast_tool_id) {random_id}
    let(:egrades_id) {random_id}
    let(:accounts_mocks) do
      external_accounts_hash = {}
      Canvas::ExternalAppConfigurations.refresh_accounts.each do |account_id|
        external_accounts_hash[account_id] = {
          fake_proxy: instance_double(Canvas::ExternalTools),
          received_creates: [],
          received_resets: []
        }
      end
      external_accounts_hash[Settings.canvas_proxy.account_id][:tools_feed] = [
        {
          'consumer_key' => 'xx',
          'id' => unknown_tool_id,
          'name' => 'Attendance Tool',
          'url' => 'https://rollcall.instructure.com/launch'
        },
        {
          'consumer_key' => random_id,
          'id' => webcast_tool_id,
          'name' => 'America\'s Highest Educational Videos',
          'url' => "#{Settings.canvas_proxy.app_provider_host}/canvas/embedded/course_mediacasts"
        }
      ]
      external_accounts_hash[Settings.canvas_proxy.official_courses_account_id][:tools_feed] = [
        {
          'consumer_key' => random_id,
          'id' => egrades_id,
          'name' => 'Download E-Grades',
          'url' => 'https://not.really.the.same.webhost/canvas/embedded/course_grade_export'
        }
      ]
      external_accounts_hash
    end
    before do
      Canvas::ExternalAppConfigurations.refresh_accounts.each do |account_id|
        account_mock = accounts_mocks[account_id]
        allow(Canvas::ExternalTools).to receive(:new).with({canvas_account_id: account_id}).and_return(account_mock[:fake_proxy])
        allow(account_mock[:fake_proxy]).to receive(:external_tools_list).and_return(account_mock[:tools_feed])
        allow(account_mock[:fake_proxy]).to receive(:create_external_tool_by_xml) do |tool_name, xml_string|
          account_mock[:received_creates] << tool_name
          {'id' => random_id}
        end
        allow(account_mock[:fake_proxy]).to receive(:reset_external_tool_by_xml) do |tool_id, xml_string|
          account_mock[:received_resets] << tool_id
          {'id' => tool_id}
        end
      end
    end
    it 'overwrites existing known apps and adds others' do
      Canvas::ReconfigureExternalApps.new.configure_all_apps_from_current_host
      main_account = accounts_mocks[Settings.canvas_proxy.account_id]
      expect(main_account[:received_resets]).to eq [webcast_tool_id]
      expect(main_account[:received_creates]).to include 'Find a Person to Add'
      official_courses_account = accounts_mocks[Settings.canvas_proxy.official_courses_account_id]
      expect(official_courses_account[:received_resets]).to eq [egrades_id]
      expect(official_courses_account[:received_creates]).to include 'Roster Photos'
    end
    describe 'feature-flag Official Sections' do
      before do
        allow(Settings.features).to receive(:course_manage_official_sections).and_return(feature_flag)
      end
      subject do
        Canvas::ReconfigureExternalApps.new.configure_all_apps_from_current_host
        accounts_mocks[Settings.canvas_proxy.official_courses_account_id][:received_creates]
      end
      context 'enabled' do
        let(:feature_flag) {true}
        it { should include 'Official Sections' }
      end
      context 'disabled' do
        let(:feature_flag) {false}
        it { should_not include 'Official Sections' }
      end
    end
  end

end
