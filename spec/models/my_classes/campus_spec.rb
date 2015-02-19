require 'spec_helper'

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
        expect(course[:site_url].blank?).to be_falsey
        expect(course[:sections]).to_not be_empty
      end
    end
  end

  describe '#fetch' do
    before {CampusOracle::UserCourses::All.stub(:new).with(user_id: user_id).and_return(double(get_all_campus_courses: fake_campus))}
    subject { MyClasses::Campus.new(user_id).fetch }
    context 'when enrolled in a current class' do
      it_behaves_like 'a Classes list'
    end
    context 'when enrolled in a non-current term' do
      let(:term_yr) {2012}
      its(:size) {should eq 0}
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
        }
      ]}
      it_behaves_like 'a Classes list'
      its(:size) {should eq fake_sections.size}
      it 'treats them as two different classes with the same URL' do
        expect(subject[0][:listings][0][:id]).to_not eq subject[1][:listings][0][:id]
        [subject, fake_sections].transpose.each do |course, enrollment|
          expect(course[:listings].first[:courseCodeSection]).to eq "#{enrollment[:instruction_format]} #{enrollment[:section_number]}"
          expect(course[:sections].size).to eq 1
          expect(course[:sections][0][:ccn]).to eq enrollment[:ccn]
          if (enrollment[:waitlistPosition] > 0)
            expect(course[:enroll_limit]).to eq enrollment[:enroll_limit]
            expect(course[:waitlistPosition]).to eq enrollment[:waitlistPosition]
          end
        end
      end
    end
  end

  context 'cross-listed courses', if: CampusOracle::Connection.test_data? do
    include_context 'instructor for crosslisted courses'
    subject { MyClasses::Campus.new("212388").fetch }
    it_should_behave_like 'a feed including crosslisted courses'
  end

end
