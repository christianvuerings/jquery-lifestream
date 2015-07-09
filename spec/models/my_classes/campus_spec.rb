describe MyClasses::Campus do
  let(:user_id) {rand(99999).to_s}
  let(:catid) {"#{rand(999)}B"}
  let(:course_code) { "ECON #{catid}" }
  let(:course_id) {"econ-#{catid}-#{term_yr}-#{term_cd}"}
  let(:term_yr) {2013}
  let(:term_cd) {'D'}
  let(:fake_sections) {[
    {
      ccn: rand(99999),
      instruction_format: 'LEC',
      is_primary_section: true
    }
  ]}
  let(:fake_campus_course) {{
    id: course_id,
    term_yr: term_yr,
    term_cd: term_cd,
    catid: catid,
    dept: 'ECON',
    course_code: course_code,
    course_option: 'E1',
    emitter: 'Campus',
    name: 'Retire in Only 85 Years',
    role: 'Student',
    sections: fake_sections
  }}
  let(:fake_campus) do
    {
      "#{term_yr}-#{term_cd}" => [fake_campus_course]
    }
  end

  shared_examples 'a Classes list' do
    its(:size) {should > 0}
    it 'sets the usual fields' do
      subject.each do |course|
        expect(course[:emitter]).to eq CampusOracle::UserCourses::APP_ID
        expect(course[:listings].length).to eq 1
        expect(course[:listings].first[:catid]).to eq catid
        expect(course[:listings].first[:course_code]).to eq course_code
        expect(course[:site_url]).to be_present
        expect(course[:sections]).to_not be_empty
      end
    end
  end

  describe '#fetch' do
    before {CampusOracle::UserCourses::All.stub(:new).with(user_id: user_id).and_return(double(get_all_campus_courses: fake_campus))}
    let(:campus_classes) { MyClasses::Campus.new(user_id).fetch }
    context 'when enrolled in a current class' do
      subject { campus_classes[:current] }
      it_behaves_like 'a Classes list'
      it 'omits grading in progress classes' do
        expect(campus_classes).not_to include :gradingInProgress
      end
    end
    context 'when enrolled in a non-current term' do
      let(:term_yr) {2012}
      it 'lists no current classes' do
        expect(campus_classes[:current]).to be_empty
      end
    end
    context 'when student in two primary sections with the same department and catalog ID' do
      let(:fake_sections) {[
        {
          ccn: '76378',
          enroll_status: 'E',
          instruction_format: 'FLD',
          is_primary_section: true,
          pnp_flag: 'Y ',
          unit: '3',
          section_number: '012',
          waitlistPosition: 0
        },
        {
          ccn: '76392',
          enroll_status: 'W',
          enroll_limit: 20,
          instruction_format: 'FLD',
          is_primary_section: true,
          pnp_flag: 'N ',
          unit: '2',
          section_number: '021',
          waitlistPosition: 2
        },
        {
          ccn: '76393',
          enroll_status: 'E',
          instruction_format: 'DIS',
          is_primary_section: false,
          pnp_flag: 'N ',
          unit: '0',
          section_number: '200',
          waitlistPosition: 0
        }
      ]}
      subject { campus_classes[:current] }
      it_behaves_like 'a Classes list'
      its(:size) {should eq 2}
      it 'treats them as two different classes' do
        expect(subject[0][:listings][0][:id]).to_not eq subject[1][:listings][0][:id]
        expect(subject[0][:site_url]).to_not eq subject[1][:site_url]
        [subject, fake_sections[0..1]].transpose.each do |course, enrollment|
          expect(course[:listings].first[:courseCodeSection]).to eq "#{enrollment[:instruction_format]} #{enrollment[:section_number]}"
          expect(course[:sections][0][:ccn]).to eq enrollment[:ccn]
          if (enrollment[:waitlistPosition] > 0)
            expect(course[:enroll_limit]).to eq enrollment[:enroll_limit]
            expect(course[:waitlistPosition]).to eq enrollment[:waitlistPosition]
          end
        end
      end
      it 'associates secondary sections based on course_option' do
        expect(subject[0][:sections].size).to eq 2
        expect(subject[1][:sections].size).to eq 1
      end
    end
    context 'when term has just ended' do
      before { allow(Settings.terms).to receive(:fake_now).and_return(DateTime.parse('2013-12-30')) }
      it 'includes empty current term' do
        expect(campus_classes[:current]).to be_empty
      end
      subject { campus_classes[:gradingInProgress] }
      it_behaves_like 'a Classes list'
    end
  end

  context 'cross-listed courses', if: CampusOracle::Connection.test_data? do
    include_context 'instructor for crosslisted courses'
    subject { MyClasses::Campus.new('212388').fetch[:current] }
    it_should_behave_like 'a feed including crosslisted courses'
  end

end
