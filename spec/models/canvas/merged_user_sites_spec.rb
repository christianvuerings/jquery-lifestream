describe Canvas::MergedUserSites do
  let(:uid) { rand(999999).to_s }
  let(:canvas_course_id) { rand(999999) }
  let(:canvas_course) { {
    'id' => canvas_course_id,
    'course_code' => "ANTHRO #{canvas_course_id}",
    'name' => "#{canvas_course_id} words for snow",
    'term' => {
      'name' => 'Fall 2013'
    }
  } }

  shared_examples 'a course site item' do
    its([:id]) {should eq(canvas_course_id.to_s)}
    its([:site_url]) {should eq("#{Settings.canvas_proxy.url_root}/courses/#{canvas_course_id}")}
    its([:name]) {should eq(canvas_course['course_code'])}
    its([:shortDescription]) {should eq(canvas_course['name'])}
    its([:emitter]) {should eq(Canvas::Proxy::APP_NAME)}
  end

  describe '#merge_course_with_sections' do
    let(:canvas_section_id) { rand(999999) }
    let(:canvas_section_base) {{
      'id' => canvas_section_id,
      'course_id' => canvas_course_id,
      'name' => "Section #{canvas_section_id}"
    }}
    subject { Canvas::MergedUserSites.new(uid).merge_course_with_sections(canvas_course, [canvas_section]) }
    context 'when a Canvas section has a possible SIS link' do
      let(:ccn) { random_ccn }
      let(:canvas_section) {canvas_section_base.merge({ 'sis_section_id' => "SEC:2013-D-#{ccn}" })}
      its([:term_yr]) {should eq('2013')}
      its([:term_cd]) {should eq('D')}
      its([:sections]) {should eq([{ccn: ccn}])}
    end
    context 'when a Canvas section is not associated with a campus section' do
      let(:canvas_section) {canvas_section_base.merge({ 'sis_section_id' => "Something Else" })}
      it_behaves_like 'a course site item'
      its([:term_yr]) {should eq('2013')}
      its([:term_cd]) {should eq('D')}
      its([:sections]) {should be_empty}
    end
    context 'when the Canvas course is not in a standard term' do
      let(:canvas_section) {canvas_section_base.merge({ 'sis_section_id' => nil })}
      before {canvas_course['term'] = {'name' => 'Default Term'}}
      it_behaves_like 'a course site item'
      its([:term_yr]) {should be_nil}
      its([:term_cd]) {should be_nil}
      its([:sections]) {should be_empty}
    end
  end

  describe '#merge_groups' do
    let(:canvas_group_id) { rand(999999) }
    let(:canvas_group_base) {{
      'id' => canvas_group_id,
      'name' => "Group #{canvas_group_id}"
    }}

    shared_examples 'a group site item' do
      its([:id]) {should eq(canvas_group_id.to_s)}
      its([:site_url]) {should eq("#{Settings.canvas_proxy.url_root}/groups/#{canvas_group_id}")}
      its([:name]) {should eq(canvas_group['name'])}
      its([:emitter]) {should eq(Canvas::Proxy::APP_NAME)}
    end

    let(:merged_sites) {{
      courses: [{
        id: canvas_course_id.to_s,
        site_url: "#{Settings.canvas_proxy.url_root}/courses/#{canvas_course_id}",
        name: canvas_course['course_code'],
        shortDescription: canvas_course['name']
      }],
      groups: []
    }}
    subject {
      Canvas::MergedUserSites.new(uid).get_group_data(canvas_group)
    }
    context 'when a Canvas group site is associated with a course site' do
      let(:canvas_group) {canvas_group_base.merge({ 'context_type' => 'Course', 'course_id' => canvas_course_id })}
      it_behaves_like 'a group site item'
      it 'reports association by course id' do
        expect(subject[:course_id]).to eq canvas_course_id.to_s
      end
    end
    context 'when a Canvas group site is associated with an account' do
      let(:canvas_group) {canvas_group_base.merge({ 'context_type' => 'Account', 'account_id' => rand(999999) })}
      it_behaves_like 'a group site item'
      its([:course_id]) { should be_nil }
    end
  end

end
