require "spec_helper"

describe CanvasReconfigureExternalApps do
  let(:fake_canvas_host) {'https://ucberkeley.beta.instructure.com'}
  let(:fake_calcentral_host) {'cc-dev.example.com'}
  let(:reachable_xml_host) {'http://example.com'}
  let(:fake_external_tools_proxy) {CanvasExternalToolsProxy.new(fake: true)}
  let(:fake_reset_response) {double(nil, status: 200, body: {}.to_json)}

  context 'when servers need resetting' do
    let(:new_calcentral_host) {'jabberwock.example.com'}
    it "resets all hosted apps" do
      fake_external_tools_list = fake_external_tools_proxy.external_tools_list
      external_tools_proxy = double()
      external_tools_proxy.should_receive(:external_tools_list).and_return(fake_external_tools_list)
      external_tools_proxy.should_receive(:reset_external_tool).exactly(3).times.and_return(fake_reset_response)
      CanvasExternalToolsProxy.stub(:new).with({url_root: fake_canvas_host}).and_return(external_tools_proxy)
      CanvasReconfigureExternalApps.reconfigure_external_apps(reachable_xml_host, [
        {host: fake_canvas_host, calcentral: new_calcentral_host}
      ])
    end
  end

  context 'when servers are already up to date' do
    it "leaves hosted apps alone" do
      fake_external_tools_list = fake_external_tools_proxy.external_tools_list
      external_tools_proxy = double()
      external_tools_proxy.should_receive(:external_tools_list).and_return(fake_external_tools_list)
      external_tools_proxy.should_not_receive(:reset_external_tool)
      CanvasExternalToolsProxy.stub(:new).with({url_root: fake_canvas_host}).and_return(external_tools_proxy)
      CanvasReconfigureExternalApps.reconfigure_external_apps(reachable_xml_host, [
        {host: fake_canvas_host, calcentral: fake_calcentral_host}
      ])
    end
  end

end
