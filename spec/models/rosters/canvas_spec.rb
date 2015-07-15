describe Rosters::Canvas do

  let(:teacher_login_id) { rand(99999).to_s }
  let(:course_id) { rand(99999) }
  let(:catid) {"#{rand(999)}"}

  let(:lecture_section_id) { rand(99999) }
  let(:lecture_section_ccn) { rand(9999).to_s }
  let(:lecture_section_sis_id) { "SEC:2013-C-#{lecture_section_ccn}" }

  let(:discussion_section_id) { rand(99999) }
  let(:discussion_section_ccn) { rand(9999).to_s }
  let(:discussion_section_sis_id) { "SEC:2013-C-#{discussion_section_ccn}" }

  let(:section_identifiers) {[
    {
      'course_id' => course_id,
      'id' => lecture_section_id,
      'name' => 'An Official Lecture Section',
      'sis_section_id' => lecture_section_sis_id,
      :term_yr => '2013',
      :term_cd => 'C',
      :ccn => lecture_section_ccn
    },
    {
      'course_id' => course_id,
      'id' => discussion_section_id,
      'name' => 'An Official Discussion Section',
      'sis_section_id' => discussion_section_sis_id,
      :term_yr => '2013',
      :term_cd => 'C',
      :ccn => discussion_section_ccn
    }
  ]}

  subject { Rosters::Canvas.new(teacher_login_id, course_id: course_id) }

  before do
    allow_any_instance_of(Canvas::Course).to receive(:course).and_return(
      {statusCode: 200,
       body: {
        'account_id'=>rand(9999),
        'course_code'=>"INFO #{catid} - LEC 001",
        'id'=>course_id,
        'name'=>'An Official Course',
        'term'=>{
          'id'=>rand(9999), 'name'=>'Summer 2013', 'sis_term_id'=>'TERM:2013-C'
        },
        'sis_course_id'=>"CRS:INFO-#{catid}-2013-C",
      }
    })
  end

  context 'when students are enrolled in multiple sections' do
    let(:student_in_discussion_section_login_id) { rand(99999).to_s }
    let(:student_in_discussion_section_student_id) { rand(99999).to_s }

    let(:student_not_in_discussion_section_login_id) { rand(99999).to_s }
    let(:student_not_in_discussion_section_student_id) { rand(99999).to_s }

    before do
      stub_teacher_status(teacher_login_id, course_id)
      allow_any_instance_of(Canvas::CourseSections).to receive(:official_section_identifiers).and_return(section_identifiers)
      allow(CampusOracle::Queries).to receive(:get_enrolled_students).with(lecture_section_ccn, '2013', 'C').and_return(
        [
          {
            'ldap_uid' => student_in_discussion_section_login_id,
            'enroll_status' => 'E',
            'student_id' => student_in_discussion_section_student_id,
            'first_name' => 'Thurston',
            'last_name' => "Howell #{student_in_discussion_section_login_id}",
            'student_email_address' => "#{student_in_discussion_section_login_id}@example.com"
          },
          {
            'ldap_uid' => student_not_in_discussion_section_login_id,
            'enroll_status' => 'E',
            'student_id' => student_not_in_discussion_section_student_id,
            'first_name' => 'Clarence',
            'last_name' => "Williams #{student_not_in_discussion_section_login_id}",
            'student_email_address' => "#{student_not_in_discussion_section_login_id}@example.com"
          }
        ]
      )
      allow(CampusOracle::Queries).to receive(:get_enrolled_students).with(discussion_section_ccn, '2013', 'C').and_return(
        [
          {
            'ldap_uid' => student_in_discussion_section_login_id,
            'enroll_status' => 'E',
            'student_id' => student_in_discussion_section_student_id,
            'first_name' => 'Thurston',
            'last_name' => "Howell #{student_in_discussion_section_login_id}",
            'student_email_address' => "#{student_in_discussion_section_login_id}@example.com"
          }
        ]
      )
    end

    it 'should return enrollments for each section' do
      feed = subject.get_feed
      expect(feed[:canvas_course][:id]).to eq course_id
      expect(feed[:canvas_course][:name]).to eq 'An Official Course'
      expect(feed[:sections].length).to eq 2
      expect(feed[:sections][0][:name]).to eq section_identifiers[0]['name']
      expect(feed[:sections][0][:ccn]).to eq section_identifiers[0][:ccn]
      expect(feed[:sections][0][:sis_id]).to eq section_identifiers[0]['sis_section_id']
      expect(feed[:sections][1][:name]).to eq section_identifiers[1]['name']
      expect(feed[:sections][1][:ccn]).to eq section_identifiers[1][:ccn]
      expect(feed[:sections][1][:sis_id]).to eq section_identifiers[1]['sis_section_id']
      expect(feed[:students].length).to eq 2

      student_in_discussion_section = feed[:students].find{|student| student[:student_id] == student_in_discussion_section_student_id}
      expect(student_in_discussion_section).to_not be_nil
      expect(student_in_discussion_section[:id]).to eq student_in_discussion_section_login_id
      expect(student_in_discussion_section[:login_id]).to eq student_in_discussion_section_login_id
      expect(student_in_discussion_section[:first_name]).to_not be_blank
      expect(student_in_discussion_section[:last_name]).to_not be_blank
      expect(student_in_discussion_section[:email]).to_not be_blank
      expect(student_in_discussion_section[:sections].length).to eq 2
      expect(student_in_discussion_section[:sections][0][:ccn]).to eq lecture_section_ccn
      expect(student_in_discussion_section[:sections][0][:name]).to eq 'An Official Lecture Section'
      expect(student_in_discussion_section[:sections][0][:sis_id]).to eq lecture_section_sis_id
      expect(student_in_discussion_section[:sections][1][:ccn]).to eq discussion_section_ccn
      expect(student_in_discussion_section[:sections][1][:name]).to eq 'An Official Discussion Section'
      expect(student_in_discussion_section[:sections][1][:sis_id]).to eq discussion_section_sis_id
      expect(student_in_discussion_section[:section_ccns].length).to eq 2
      expect(student_in_discussion_section[:section_ccns].first).to be_a String

      student_not_in_discussion_section = feed[:students].find{|student| student[:student_id] == student_not_in_discussion_section_student_id}
      expect(student_not_in_discussion_section).to_not be_nil
      expect(student_not_in_discussion_section[:id]).to eq student_not_in_discussion_section_login_id
      expect(student_not_in_discussion_section[:login_id]).to eq student_not_in_discussion_section_login_id
      expect(student_not_in_discussion_section[:first_name]).to_not be_blank
      expect(student_not_in_discussion_section[:last_name]).to_not be_blank
      expect(student_not_in_discussion_section[:email]).to_not be_blank
      expect(student_not_in_discussion_section[:sections].length).to eq 1
      expect(student_not_in_discussion_section[:sections][0][:ccn]).to eq lecture_section_ccn
      expect(student_not_in_discussion_section[:sections][0][:name]).to eq 'An Official Lecture Section'
      expect(student_not_in_discussion_section[:sections][0][:sis_id]).to eq lecture_section_sis_id
      expect(student_not_in_discussion_section[:section_ccns].length).to eq 1
      expect(student_not_in_discussion_section[:section_ccns].first).to be_a String
    end
  end

  context 'when students are waitlisted' do
    let(:enrolled_student_login_id) { rand(99999).to_s }
    let(:enrolled_student_student_id) { rand(99999).to_s }

    let(:waitlisted_student_login_id) { rand(99999).to_s }
    let(:waitlisted_student_student_id) { rand(99999).to_s }

    it 'should show official photo links for students who are not waitlisted in all sections' do
      stub_teacher_status(teacher_login_id, course_id)
      allow_any_instance_of(Canvas::CourseSections).to receive(:official_section_identifiers).and_return(
        [
          {
            course_id: course_id,
            id: lecture_section_id,
            name: 'An Official Lecture Section',
            sis_section_id: lecture_section_sis_id,
            term_yr: '2013',
            term_cd: 'C',
            ccn: lecture_section_ccn
          },
          {
            course_id: course_id,
            id: discussion_section_id,
            name: 'An Official Discussion Section',
            sis_section_id: discussion_section_sis_id,
            term_yr: '2013',
            term_cd: 'C',
            ccn: discussion_section_ccn
          }
        ]
      )

      # A student may be waitlisted in a secondary section but enrolled in a primary section.
      allow(CampusOracle::Queries).to receive(:get_enrolled_students).with(lecture_section_ccn, '2013', 'C').and_return(
        [
          {
            'ldap_uid' => enrolled_student_login_id,
            'enroll_status' => 'E',
            'student_id' => enrolled_student_student_id,
            'photo_bytes' => '8203.0'
          },
          {
            'ldap_uid' => waitlisted_student_login_id,
            'enroll_status' => 'W',
            'student_id' => waitlisted_student_student_id,
            'photo_bytes' => '7834.1'
          }
        ]
      )
      allow(CampusOracle::Queries).to receive(:get_enrolled_students).with(discussion_section_ccn, '2013', 'C').and_return(
        [
          {
            'ldap_uid' => enrolled_student_login_id,
            'enroll_status' => 'W',
            'student_id' => enrolled_student_student_id,
            'photo_bytes' => '8203.0'
          },
          {
            'ldap_uid' => waitlisted_student_login_id,
            'enroll_status' => 'W',
            'student_id' => waitlisted_student_student_id,
            'photo_bytes' => '7834.1'
          }
        ]
      )
      feed = subject.get_feed
      expect(feed[:sections].length).to eq 2
      expect(feed[:students].length).to eq 2

      enrolled_student = feed[:students].find {|student| student[:login_id] == enrolled_student_login_id}
      expect(enrolled_student).to_not be_nil
      expect(enrolled_student[:photo]).to_not be_blank

      waitlisted_student = feed[:students].find {|student| student[:login_id] == waitlisted_student_login_id}
      expect(waitlisted_student).to_not be_nil
      expect(waitlisted_student[:photo]).to be_nil
    end

    it 'should only download photo data for officially fully enrolled students' do
      stub_teacher_status(teacher_login_id, course_id)
      allow_any_instance_of(Canvas::CourseSections).to receive(:official_section_identifiers).and_return(
        [
          {
            course_id: course_id,
            id: lecture_section_id,
            name: 'An Official Lecture Section',
            sis_section_id: lecture_section_sis_id,
            term_yr: "2013",
            term_cd: "C",
            ccn: lecture_section_ccn
          }
        ]
      )
      allow(CampusOracle::Queries).to receive(:get_enrolled_students).with(lecture_section_ccn, '2013', 'C').and_return(
        [
          {
            'ldap_uid' => enrolled_student_login_id,
            'enroll_status' => 'E',
            'student_id' => enrolled_student_student_id,
            'photo_bytes' => '8203.0'
          },
          {
            'ldap_uid' => waitlisted_student_login_id,
            'enroll_status' => 'W',
            'student_id' => waitlisted_student_student_id,
            'photo_bytes' => '7834.1'
          }
        ]
      )
      photo_data = rand(99999999)
      allow(CampusOracle::Queries).to receive(:get_photo).with(enrolled_student_login_id).and_return(
        {
          'bytes' => 42,
          'photo' => photo_data
        }
      )
      enrolled_photo = subject.photo_data_or_file(enrolled_student_login_id)
      expect(enrolled_photo[:data]).to eq photo_data
      expect(enrolled_photo[:size]).to eq 42
      expect(enrolled_photo[:filename]).to be_nil
      waitlisted_photo = subject.photo_data_or_file(waitlisted_student_login_id)
      expect(waitlisted_photo).to be_nil
    end
  end

  context 'when profile URL requested for LDAP ID' do
    let(:student_canvas_id) { rand(999999) }
    let(:student_sis_login_id) { rand(999999).to_s }
    let(:student_sis_user_id) { rand(999999).to_s }

    before do
      allow_any_instance_of(Canvas::SisUserProfile).to receive(:get).and_return(
        {
           'id' => student_canvas_id,
           'login_id' => student_sis_login_id,
           'sis_user_id' => student_sis_user_id,
           'sis_login_id' => student_sis_login_id
        }
      )
    end

    it 'returns a correctly formatted URL' do
      profile_url = subject.profile_url_for_ldap_id(student_sis_login_id)
      expect(profile_url).to eq "#{Settings.canvas_proxy.url_root}/courses/#{course_id}/users/#{student_canvas_id}"
    end

    context 'when no logins match LDAP ID' do
      before { allow_any_instance_of(Canvas::SisUserProfile).to receive(:get).and_return nil }
      it 'returns nil' do
        profile_url = subject.profile_url_for_ldap_id(student_sis_login_id)
        expect(profile_url).to eq nil
      end
    end
  end

  def stub_teacher_status(teacher_login_id, canvas_course_id)
    teaching_proxy = double()
    allow(teaching_proxy).to receive(:full_teachers_list).and_return(
      {
        statusCode: 200,
        body: [
          {
            'id' => rand(99999),
            'login_id' => teacher_login_id
          }
        ]
      }
    )
    allow(Canvas::CourseTeachers).to receive(:new).with(course_id: canvas_course_id).and_return(teaching_proxy)
  end

end
