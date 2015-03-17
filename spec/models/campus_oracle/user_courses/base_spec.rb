require 'spec_helper'

describe CampusOracle::UserCourses::Base do

  describe '#merge_enrollments' do
    let(:user_id) {rand(99999).to_s}
    let(:catalog_id) {"#{rand(999)}"}
    let(:term_yr) {2013}
    let(:term_cd) {'D'}
    context 'student in two primary sections with the same department and catalog ID' do
      let(:base_enrollment) {
        {
          'dept_description' => 'Public Health',
          'term_yr' => term_yr,
          'term_cd' => term_cd,
          'enroll_status' => 'E',
          'course_title' => 'Field Study in Public Health',
          'dept_name' => 'PB HLTH',
          'catalog_id' => '297',
          'primary_secondary_cd' => 'P',
          'instruction_format' => 'FLD',
          'catalog_root' => '297',
          'enroll_limit' => 40,
          'cred_cd' => 'SU'
        }
      }
      let(:fake_enrollments) {
        [
          base_enrollment.merge({
              'course_cntl_num' => '76378',
              'enroll_status' => 'E',
              'pnp_flag' => 'Y ',
              'unit' => '3',
              'section_num' => '012',
              'wait_list_seq_num' => BigDecimal.new(0),
              'grade' => '  '
            }),
          base_enrollment.merge({
              'course_cntl_num' => '76392',
              'enroll_status' => 'W',
              'pnp_flag' => 'N ',
              'unit' => '2',
              'section_num' => '021',
              'wait_list_seq_num' => BigDecimal.new(2),
              'grade' => 'B '
            })
        ]
      }
      let(:feed) { {} }
      before {CampusOracle::Queries.stub(:get_enrolled_sections).and_return(fake_enrollments)}
      subject {
        CampusOracle::UserCourses::Base.new(user_id: user_id).merge_enrollments(feed)
        feed["#{term_yr}-#{term_cd}"]
      }
      its(:size) {should eq 1}
      it 'includes only course info at the course level' do
        course = subject.first
        expect(course[:course_code]).to eq "#{base_enrollment['dept_name']} #{base_enrollment['catalog_id']}"
        expect(course[:catid]).to eq base_enrollment['catalog_id']
        expect(course[:cred_cd]).to be_nil
        expect(course[:pnp_flag]).to be_nil
        expect(course[:cred_cd]).to be_nil
      end
      it 'includes grading information in each primary section' do
        course = subject.first
        expect(course[:sections].size).to eq 2
        [course[:sections], fake_enrollments].transpose.each do |section, enrollment|
          expect(section[:instruction_format]).to eq enrollment['instruction_format']
          expect(section[:section_label]).to_not be_empty
          expect(section[:section_number]).to eq enrollment['section_num']
          expect(section[:ccn]).to eq enrollment['course_cntl_num']
          expect(section[:cred_cd]).to eq enrollment['cred_cd']
          expect(section[:pnp_flag]).to eq enrollment['pnp_flag']
          expect(section[:section_number]).to eq enrollment['section_num']
          expect(section[:units]).to eq enrollment['unit']
          expect(section[:waitlistPosition]).to eq enrollment['wait_list_seq_num'] if enrollment['enroll_status'] == 'W'
        end
      end
      it 'includes only non-blank grades' do
        course = subject.first
        expect(course[:sections][0]).not_to include(:grade)
        expect(course[:sections][1][:grade]).to eq 'B'
      end
    end
  end

  describe '#course_ids_from_row' do
    let(:row) {{
      'catalog_id' => "0109AL",
      'dept_name' => 'MEC ENG/I,RES',
      'term_yr' => '2014',
      'term_cd' => 'B'
    }}
    subject {CampusOracle::UserCourses::Base.new(user_id: rand(99)).course_ids_from_row(row)}
    its([:slug]) {should eq "mec_eng_i_res-0109al"}
    its([:id]) {should eq "mec_eng_i_res-0109al-2014-B"}
    its([:course_code]) {should eq 'MEC ENG/I,RES 0109AL'}
  end

  describe '#row_to_feed_item' do
    let(:row) {{
      'catalog_id' => "0109AL",
      'dept_name' => 'MEC ENG/I,RES',
      'term_yr' => '2014',
      'term_cd' => 'B',
      'course_title' => course_title,
      'course_title_short' => '17TH-18TH CENTURY'
    }}
    subject {CampusOracle::UserCourses::Base.new(user_id: random_id).row_to_feed_item(row, {})}
    context 'course has a nice long title' do
      let(:course_title) {'Museum Internship'}
      it 'uses the official title' do
        expect(subject[:name]).to eq course_title
      end
    end
    context 'course has a null COURSE_TITLE column' do
      let(:course_title) {nil}
      it 'uses the official title' do
        expect(subject[:name]).to eq row['course_title_short']
      end
    end
  end

end
