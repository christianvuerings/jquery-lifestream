require "spec_helper"

describe MyAcademics::CanvasSites do
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

  subject do
    MyAcademics::CanvasSites.new(uid).merge(fake_feed)
  end

  context 'with no Canvas account' do
    before {Canvas::Proxy.stub(:access_granted?).with(uid).and_return(false)}
    it 'quietly does nothing' do
      expect(subject).to eq fake_feed
    end
  end

  def it_is_a_normal_course_site_item(site)
    expect(site[:id]).to eq canvas_site_id
    expect(site[:emitter]).to eq Canvas::Proxy::APP_NAME
    expect(site[:name]).to eq canvas_site_base[:name]
    expect(site[:shortDescription]).to eq canvas_site_base[:shortDescription]
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

  context 'with Canvas course site memberships' do
    let(:canvas_site_id) { rand(99999).to_s }
    let(:canvas_site_base) do
      {
        id: canvas_site_id,
        site_url: "something/#{canvas_site_id}",
        name: "CODE #{ccn}",
        shortDescription: "A barrel of #{ccn} monkeys",
        term_yr: term_yr,
        term_cd: term_cd,
        emitter: Canvas::Proxy::APP_NAME
      }
    end
    let(:group_id) { rand(99999).to_s }
    let(:group_base) do
      {
        id: group_id,
        name: "Group #{group_id}",
        site_url: "somewhere/#{group_id}",
        emitter: Canvas::Proxy::APP_NAME
      }
    end
    before { Canvas::Proxy.stub(:access_granted?).with(uid).and_return(true) }
    before { Canvas::MergedUserSites.stub(:new).with(uid).and_return(double(get_feed: canvas_sites)) }

    context 'when the Canvas site has an academic term' do
      let(:term_yr) {fake_term_yr}
      let(:term_cd) {fake_term_cd}
      context 'when the Canvas course site matches a campus section' do
        let(:canvas_site) {canvas_site_base.merge({sections: [{ccn: ccn.to_s}]})}
        let(:canvas_sites) {{courses: [canvas_site], groups: []}}
        context 'when the user is an instructor' do
          let(:teaching_classes) {[campus_course_base]}
          it 'includes the site in the campus class item' do
            it_is_a_linked_course_site_item(:teachingSemesters)
          end

          # By default, CCN strings are filled out to five digits by prefixing zeroes.
          # However, shorter strings should still match.
          context 'when the Canvas section CCN does not prefix zero' do
            let(:ccn_int) {rand(999)}
            let(:ccn) {"00#{ccn_int}"}
            let(:canvas_site) {canvas_site_base.merge({sections: [{ccn: ccn_int.to_s}]})}
            it 'points back to campus course' do
              it_is_a_linked_course_site_item(:teachingSemesters)
            end
          end

          context 'when the Canvas group site links to a matching course site' do
            let(:group) {group_base.merge(course_id: canvas_site_id)}
            let(:canvas_sites) {{courses: [canvas_site], groups: [group]}}
            it 'is included with the campus course' do
              sites = subject[:teachingSemesters].first[:classes].first[:class_sites]
              expect(sites).to have(2).items
              site = sites.select{|s| s[:siteType] == 'group'}.first
              expect(site[:id]).to eq group_id
              expect(site[:emitter]).to eq Canvas::Proxy::APP_NAME
              expect(site[:name]).to eq group_base[:name]
              expect(site[:siteType]).to eq 'group'
              expect(site[:source]).to eq canvas_site_base[:name]
            end
          end
        end

        context 'when the user is a student' do
          let(:student_classes) {[campus_course_base]}
          it 'includes the site in the campus class item' do
            it_is_a_linked_course_site_item(:semesters)
          end
        end

      end

      context 'when the Canvas course site does not match a known campus section' do
        let(:canvas_site) {canvas_site_base.merge({sections: [{ccn: rand(99999).to_s}]})}
        let(:canvas_sites) {{courses: [canvas_site], groups: []}}
        let(:teaching_classes) {[campus_course_base]}
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

    context 'when the Canvas site does not take place in an academic term' do
      let(:term_yr) { nil }
      let(:term_cd) { nil }
      let(:canvas_sites) { {courses: [canvas_site_base], groups: []} }
      it 'does not belong in My Academics' do
        expect(subject).to eq fake_feed
      end
    end

  end

end
