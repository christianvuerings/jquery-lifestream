require "spec_helper"

describe Canvas::ReconfigureExternalApps do
  let(:fake_canvas_host) {'https://ucberkeley.beta.instructure.com'}
  let(:fake_calcentral_host) {'cc-dev.example.com'}
  let(:reachable_xml_host) {'http://example.com'}
  let(:fake_external_tools_proxy) {Canvas::ExternalTools.new(fake: true)}
  let(:fake_reset_response) {double(nil, status: 200, body: {}.to_json)}

  context 'when servers need resetting' do
    let(:new_calcentral_host) {'jabberwock.example.com'}
    it "resets all hosted apps" do
      fake_external_tools_list = fake_external_tools_proxy.external_tools_list
      external_tools_proxy = double()
      external_tools_proxy.should_receive(:external_tools_list).exactly(2).times.and_return(fake_external_tools_list)
      external_tools_proxy.should_receive(:reset_external_tool).exactly(8).times.and_return(fake_reset_response)
      Canvas::ExternalTools.stub(:new).with({url_root: fake_canvas_host, canvas_account_id: '90242'}).and_return(external_tools_proxy)
      Canvas::ExternalTools.stub(:new).with({url_root: fake_canvas_host, canvas_account_id: '129410'}).and_return(external_tools_proxy)
      Canvas::ReconfigureExternalApps.reconfigure_external_apps(reachable_xml_host, [
        {host: fake_canvas_host, calcentral: new_calcentral_host}
      ])
    end
  end

  context 'when servers are already up to date' do
    it "leaves hosted apps alone" do
      fake_external_tools_list = fake_external_tools_proxy.external_tools_list
      external_tools_proxy = double()
      external_tools_proxy.should_receive(:external_tools_list).twice.and_return(fake_external_tools_list)
      external_tools_proxy.should_not_receive(:reset_external_tool)
      Canvas::ExternalTools.stub(:new).with({url_root: fake_canvas_host, canvas_account_id: '90242'}).and_return(external_tools_proxy)
      Canvas::ExternalTools.stub(:new).with({url_root: fake_canvas_host, canvas_account_id: '129410'}).and_return(external_tools_proxy)
      Canvas::ReconfigureExternalApps.reconfigure_external_apps(reachable_xml_host, [
        {host: fake_canvas_host, calcentral: fake_calcentral_host}
      ])
    end
  end

  context 'when providing array of accounts requiring LTI tool refresh' do
    it 'returns primary account as well as other lti accounts' do
      accounts = Canvas::ReconfigureExternalApps.refresh_accounts
      expect(accounts).to be_an_instance_of Array
      expect(accounts[0]).to eq '90242'
      expect(accounts[1]).to eq '129410'
    end
  end

end
