require "spec_helper"

describe MyAcademics::TeachingSakai do
  let(:uid) {rand(99999).to_s}
  let(:ccn) {rand(99999)}
  let(:course_id) {"econ-#{rand(999)}B"}
  let(:campus_course_base) do
    {
      slug: course_id,
      sections: [{
        ccn: ccn.to_s
      }],
      class_sites: []
    }
  end
  let(:fake_term_yr) {2013}
  let(:fake_term_cd) {'D'}
  let(:campus_courses) do
    [{
      name: Berkeley::TermCodes.to_english(fake_term_yr, fake_term_cd),
      slug: Berkeley::TermCodes.to_slug(fake_term_yr, fake_term_cd),
      classes: [
        campus_course_base
      ]
    }]
  end
  let(:sakai_site_id) {"#{rand(99999)}-#{rand(99999)}"}
  let(:sakai_site_base) do
    {
      id: sakai_site_id,
      site_url: "something/#{sakai_site_id}",
      name: "CODE #{ccn}",
      shortDescription: "A barrel of #{ccn} monkeys",
      term_yr: term_yr,
      term_cd: term_cd,
      emitter: Sakai::Proxy::APP_ID
    }
  end
  before {Sakai::SakaiMergedUserSites.stub(:new).with(user_id: uid).and_return(double(get_feed: sakai_sites))}
  subject do
    MyAcademics::TeachingSakai.new(uid).merge_sites(campus_courses)
    campus_courses.first[:classes].first[:class_sites]
  end

  context 'when Sakai course is within a current term' do
    let(:term_yr) {fake_term_yr}
    let(:term_cd) {fake_term_cd}
    context 'when Sakai course site matches a campus section' do
      let(:sakai_site) {sakai_site_base.merge({sections: [{ccn: ccn.to_s}]})}
      let(:sakai_sites) {{courses: [sakai_site], groups: []}}
      its(:size) {should eq 1}
      it 'points back to campus course' do
        site = subject.first
        expect(site[:id]).to eq sakai_site_id
        expect(site[:emitter]).to eq Sakai::Proxy::APP_ID
        expect(site[:name]).to eq sakai_site_base[:name]
        expect(site[:sections].first[:ccn]).to eq ccn.to_s
      end
    end
    context 'when Sakai course site does not match official campus enrollment' do
      let(:sakai_site) {sakai_site_base.merge({sections: [{ccn: rand(9999).to_s}]})}
      let(:sakai_sites) {{courses: [sakai_site], groups: []}}
      its(:size) {should eq 0}
    end
  end
  context 'when Sakai course site is for a non-current term' do
    let(:term_yr) {2012}
    let(:term_cd) {fake_term_cd}
    let(:sakai_site) {sakai_site_base.merge({sections: [{ccn: ccn.to_s}]})}
    let(:sakai_sites) {{courses: [sakai_site], groups: []}}
    its(:size) {should eq 0}
  end
  context 'when a Sakai project site' do
    let(:term_yr) {nil}
    let(:term_cd) {nil}
    let(:sakai_sites) {{courses: [], groups: [sakai_site_base]}}
    its(:size) {should eq 0}
  end
end
