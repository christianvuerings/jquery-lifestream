require "spec_helper"

describe MyGroups::Canvas do
  let(:uid) {rand(99999).to_s}
  subject {MyGroups::Canvas.new(uid).fetch}

  context 'when no Canvas account' do
    before {Canvas::Proxy.stub(:access_granted?).with(uid).and_return(false)}
    it {should eq []}
  end

  describe '#merge_sites' do
    let(:site_id) {rand(99999).to_s}
    let(:site_base) do
      {
        id: site_id,
        site_url: "something/#{site_id}",
        name: "CODE #{site_id}",
        shortDescription: "#{site_id} old fashioned recipes",
        emitter: Canvas::Proxy::APP_NAME
      }
    end
    before {Canvas::Proxy.stub(:access_granted?).with(uid).and_return(true)}
    before {Canvas::MergedUserSites.stub(:new).with(uid).and_return(double(get_feed: canvas_sites))}
    context 'when a Canvas course site' do
      let(:canvas_sites) {{courses: [site_base.merge({term_yr: term_yr, term_cd: term_yr})], groups: []}}
      context 'when in a campus term' do
        let(:term_yr) {2013}
        let(:term_cd) {'D'}
        it {should eq []}
      end
      context 'when outside any campus term' do
        let(:term_yr) {nil}
        let(:term_cd) {nil}
        its(:size) {should eq 1}
        it 'includes the site' do
          site = subject.first
          expect(site[:id]).to eq site_id
          expect(site[:emitter]).to eq Canvas::Proxy::APP_NAME
          expect(site[:name]).to eq site_base[:name]
          expect(site[:shortDescription]).to eq site_base[:shortDescription]
          expect(site[:site_url]).to eq site_base[:site_url]
        end
      end
    end
    context 'when a Canvas group site' do
      let(:group_id) {rand(99999).to_s}
      let(:group_base) do
        {
          id: group_id,
          name: "Group #{group_id}",
          site_url: "somewhere/#{group_id}",
          emitter: Canvas::Proxy::APP_NAME
        }
      end
      context 'when not linked to a course site' do
        let(:canvas_sites) {{courses: [], groups: [group_base]}}
        its(:size) {should eq 1}
        it 'includes the group' do
          site = subject.first
          expect(site[:id]).to eq group_id
          expect(site[:emitter]).to eq Canvas::Proxy::APP_NAME
          expect(site[:name]).to eq group_base[:name]
          expect(site[:site_url]).to eq group_base[:site_url]
          expect(site[:courses]).to be_nil
        end
      end
      context 'when linked to a course site' do
        let(:group) {group_base.merge(course_id: site_id)}
        let(:canvas_sites) {{courses: [site_base.merge({term_yr: term_yr, term_cd: term_yr})], groups: [group]}}
        context 'when in a campus term' do
          let(:term_yr) {2013}
          let(:term_cd) {'D'}
          it {should eq []}
        end
        context 'when outside any campus term' do
          let(:term_yr) {nil}
          let(:term_cd) {nil}
          its(:size) {should eq 2}
          it 'includes both sites' do
            site = subject.select {|s| s[:id] == site_id}.first
            expect(site[:emitter]).to eq Canvas::Proxy::APP_NAME
            expect(site[:name]).to eq site_base[:name]
            expect(site[:shortDescription]).to eq site_base[:shortDescription]
            expect(site[:site_url]).to eq site_base[:site_url]
            site = subject.select {|s| s[:id] == group_id}.first
            expect(site[:emitter]).to eq Canvas::Proxy::APP_NAME
            expect(site[:name]).to eq group_base[:name]
            expect(site[:site_url]).to eq group_base[:site_url]
            expect(site[:courses]).to be_nil
          end
        end
      end
    end
  end

end
