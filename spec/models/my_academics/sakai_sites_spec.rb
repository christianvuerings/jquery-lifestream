require "spec_helper"

describe MyAcademics::SakaiSites do
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
  let(:student_classes) {[]}
  let(:teaching_classes) {[]}
  let(:fake_feed) do
    {
      semesters: [{
        name: Berkeley::TermCodes.to_english(fake_term_yr, fake_term_cd),
        slug: Berkeley::TermCodes.to_slug(fake_term_yr, fake_term_cd),
        classes: student_classes
      }],
      teachingSemesters: [{
        name: Berkeley::TermCodes.to_english(fake_term_yr, fake_term_cd),
        slug: Berkeley::TermCodes.to_slug(fake_term_yr, fake_term_cd),
        classes: teaching_classes
      }]
    }
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
    MyAcademics::SakaiSites.new(uid).merge(fake_feed)
  end

  def it_is_a_normal_course_site_item(site)
    expect(site[:id]).to eq sakai_site_id
    expect(site[:emitter]).to eq Sakai::Proxy::APP_ID
    expect(site[:name]).to eq sakai_site_base[:name]
    expect(site[:shortDescription]).to eq sakai_site_base[:shortDescription]
    expect(site[:siteType]).to eq 'course'
  end

  def it_is_a_linked_course_site_item(semester_role)
    sites = subject[semester_role].first[:classes].first[:class_sites]
    expect(sites).to have(1).item
    site = sites.first
    it_is_a_normal_course_site_item(site)
    # Both Canvas and Sakai hide course section IDs from students. CalCentral
    # honors that restriction.
    if semester_role == :teachingSemesters
      expect(site[:sections].first[:ccn]).to eq ccn.to_s
    else
      expect(site[:sections]).to be_blank
    end
  end

  context 'when Sakai course is within a current term' do
    let(:term_yr) {fake_term_yr}
    let(:term_cd) {fake_term_cd}
    context 'when Sakai course site matches a campus section' do
      let(:sakai_site) {sakai_site_base.merge({sections: [{ccn: ccn.to_s}]})}
      let(:sakai_sites) {{courses: [sakai_site], groups: []}}
      context 'when the user is an instructor' do
        let(:teaching_classes) {[campus_course_base]}
        it 'includes the site in the campus class item' do
          it_is_a_linked_course_site_item(:teachingSemesters)
        end
      end
      context 'when the user is a student' do
        let(:student_classes) {[campus_course_base]}
        it 'includes the site in the campus class item' do
          it_is_a_linked_course_site_item(:semesters)
        end
      end
    end
    context 'when Sakai course site does not match a known campus section' do
      let(:teaching_classes) {[campus_course_base]}
      let(:sakai_site) {sakai_site_base.merge({sections: [{ccn: rand(9999).to_s}]})}
      let(:sakai_sites) {{courses: [sakai_site], groups: []}}
      it 'includes the site as an unlinked site membership for the term' do
        expect(subject[:teachingSemesters].first[:classes].first[:class_sites]).to be_blank
        otherSites = subject[:otherSiteMemberships]
        expect(otherSites).to have(1).item
        term = otherSites.first
        expect(term[:termCode]).to eq fake_term_cd
        expect(term[:termYear]).to eq fake_term_yr
        expect(term[:sites]).to have(1).item
        it_is_a_normal_course_site_item(term[:sites].first)
      end
    end
  end
  context 'when a Sakai project site' do
    let(:term_yr) {nil}
    let(:term_cd) {nil}
    let(:sakai_sites) {{courses: [], groups: [sakai_site_base]}}
    it 'does not belong in My Academics' do
      expect(subject).to eq fake_feed
    end
  end

end
