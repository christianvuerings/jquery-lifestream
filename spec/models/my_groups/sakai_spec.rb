require "spec_helper"

describe MyGroups::Sakai do
  let(:uid) {rand(99999).to_s}
  let(:sakai_site_id) {"#{rand(99999)}-#{rand(99999)}"}
  let(:sakai_site_base) do
    {
      id: sakai_site_id,
      site_url: "something/#{sakai_site_id}",
      name: "CODE #{rand(999)}",
      shortDescription: "A barrel of #{rand(99)} monkeys",
      emitter: Sakai::Proxy::APP_ID
    }
  end
  before {Sakai::SakaiMergedUserSites.stub(:new).with(user_id: uid).and_return(double(get_feed: sakai_sites))}
  subject {MyGroups::Sakai.new(uid).fetch}
  context 'when a Sakai project site' do
    let(:sakai_sites) {{courses: [], groups: [sakai_site_base]}}
    its(:size) {should eq 1}
    it 'includes the site' do
      site = subject.first
      expect(site[:id]).to eq sakai_site_id
      expect(site[:emitter]).to eq Sakai::Proxy::APP_ID
      expect(site[:name]).to eq sakai_site_base[:name]
      expect(site[:site_url]).to eq sakai_site_base[:site_url]
      expect(site[:shortDescription]).to eq sakai_site_base[:shortDescription]
    end
  end
  context 'when a Sakai course site' do
    let(:sakai_site) {sakai_site_base.merge({term_yr: 2013, term_cd: 'D'})}
    let(:sakai_sites) {{courses: [sakai_site], groups: []}}
    its(:size) {should eq 0}
  end
end
