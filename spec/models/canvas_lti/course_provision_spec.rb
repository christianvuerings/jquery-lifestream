describe CanvasLti::CourseProvision do
  let(:instructor_id) { rand(99999).to_s }
  let(:user_id) { rand(99999).to_s }
  let(:canvas_admin_id) { rand(99999).to_s }
  let(:canvas_course_id) { rand(999999).to_s }
  let(:course_hash) { {'name' => 'JAVA for Minecraft Development', 'course_code' => 'COMPSCI 15B - SLF 001', 'term' => {'sis_term_id' => 'TERM:2013-D', 'name' => 'Fall 2013'}} }
  let(:teaching_ccn) { random_ccn }
  let(:official_sections) { [{:term_yr=>'2013', :term_cd=>'D', :ccn=>teaching_ccn}] }
  let(:superuser_id) { rand(99999).to_s }
  let(:teaching_section) { { :ccn => teaching_ccn, :instruction_format => 'DIS', :is_primary_section => false, :section_label => 'DIS 102', :section_number => '102' } }
  let(:teaching_class) do
    {
      :slug => 'engin-7',
      :title => 'Introduction to Computer Programming for Scientists and Engineers',
      :role => 'Instructor',
      :listings => [
        { :course_code => 'ENGIN 7', :dept => 'ENGIN' }
      ],
      :sections => [ teaching_section ]
    }
  end
  let(:teaching_semesters) {
    [
      {
        :name => 'Fall 2013',
        :slug => 'fall-2013',
        :termCode => 'D',
        :termYear => '2013',
        :classes => [ teaching_class ]
      }
    ]
  }
  let(:current_terms) {
    [
      {
        name: 'Fall 2013',
        slug: 'fall-2013'
      },
      {
        name: 'Spring 2014',
        slug: 'spring-2014'
      }
    ]
  }
  let(:by_ccns) {[rand(99999).to_s, rand(99999).to_s]}
  let(:by_ccns_semester) {'spring-2014'}
  let(:by_ccns_course_list) {
    [
      {
        :name => 'Spring 2014',
        :slug => 'spring-2014',
        :classes => [
          {
            :course_code => 'ENGIN 7',
            :dept => 'ENGIN',
            :slug => 'engin-7',
            :title => 'Introduction to Computer Programming for Scientists and Engineers',
            :sections => [
              { :ccn => by_ccns[0], :instruction_format => 'LEC', :is_primary_section => true, :section_label => 'LEC 003', :section_number => '003' },
              { :ccn => by_ccns[1], :instruction_format => 'DIS', :is_primary_section => false, :section_label => 'DIS 103', :section_number => '103' }
            ]
          }
        ]
      }
    ]
  }
  before do
    User::Auth.new_or_update_superuser!(superuser_id)
    allow_any_instance_of(Canvas::Admins).to receive(:admin_user?) {|uid| uid == canvas_admin_id }
    allow(CanvasCsv::ProvideCourseSite).to receive(:new) do |uid|
      double(
        candidate_courses_list: (uid == instructor_id) ? teaching_semesters : [],
        current_terms: current_terms,
        find_term: {yr: '2014', cd: 'B'}
      )
    end
    allow(MyAcademics::Teaching).to receive(:new).and_return(
      instance_double(MyAcademics::Teaching, {courses_list_from_ccns: by_ccns_course_list})
    )
  end

  context 'when managing existing course sections' do
    before do
      allow_any_instance_of(Canvas::CourseSections).to receive(:official_section_identifiers).and_return(official_sections)
      allow_any_instance_of(Canvas::Course).to receive(:course).and_return(course_hash)
      allow(subject).to receive(:group_by_used!) {|feed| feed}
    end
    let(:uid) { instructor_id }
    subject { CanvasLti::CourseProvision.new(uid, canvas_course_id: canvas_course_id) }
    it 'should provide sections feed with canvas course info included' do
      feed = subject.get_feed
      expect(feed[:is_admin]).to eq false
      expect(feed[:admin_acting_as]).to be_nil
      expect(feed[:teachingSemesters]).to eq teaching_semesters
      expect(feed[:admin_semesters]).to be_nil
      expect(feed[:canvas_course]).to be_an_instance_of Hash
      expect(feed[:canvas_course][:officialSections]).to eq official_sections
    end
    it 'should use group_by_used! to sort feed with associated courses listed first' do
      expect(subject).to receive(:group_by_used!) {|feed| feed}
      feed = subject.get_feed
      expect(feed[:is_admin]).to eq false
      expect(feed[:admin_acting_as]).to be_nil
      expect(feed[:teachingSemesters]).to eq teaching_semesters
    end
    describe 'tells the front-end whether to show the edit button' do
      before do
        allow_any_instance_of(Canvas::CoursePolicy).to receive(:can_edit_official_sections?).and_return(fake_can_edit)
      end
      context 'can only view sections' do
        let(:fake_can_edit) { false }
        it 'should not show Edit' do
          feed = subject.get_feed
          expect(feed[:canvas_course][:canEdit]).to be_falsey
        end
      end
      context 'can edit sections' do
        let(:fake_can_edit) { true }
        it 'should  show Edit' do
          feed = subject.get_feed
          expect(feed[:canvas_course][:canEdit]).to be_truthy
        end
      end
    end
  end

  context 'when admin acting as a user' do
    subject { CanvasLti::CourseProvision.new(uid, admin_acting_as: instructor_id) }
    context 'when a mischiefmaker' do
      let(:uid) { user_id }
      it 'should not succeed' do
        feed = subject.get_feed
        expect(feed[:is_admin]).to be_falsey
        expect(feed[:teachingSemesters]).to be_empty
      end
    end
    context 'when a Canvas admin' do
      let(:uid) { canvas_admin_id }
      it 'should find courses' do
        feed = subject.get_feed
        expect(feed[:is_admin]).to be_truthy
        expect(feed[:admin_acting_as]).to eq instructor_id
        expect(feed[:teachingSemesters]).to eq teaching_semesters
      end
    end
  end

  context 'when not admin acting as a user' do
    subject { CanvasLti::CourseProvision.new(uid) }
    context 'when a normal user' do
      let(:uid) {user_id}
      it 'should have empty feed' do
        feed = subject.get_feed
        expect(feed[:is_admin]).to eq false
        expect(feed[:admin_acting_as]).to be_nil
        expect(feed[:teachingSemesters]).to be_empty
        expect(feed[:admin_semesters]).to be_nil
      end
    end
    context 'when an instructor' do
      let(:uid) { instructor_id }
      it 'should have courses' do
        feed = subject.get_feed
        expect(feed[:is_admin]).to eq false
        expect(feed[:admin_acting_as]).to be_nil
        expect(feed[:teachingSemesters]).to eq teaching_semesters
        expect(feed[:admin_semesters]).to be_nil
      end
    end
    context 'when a Canvas admin' do
      let(:uid) { canvas_admin_id }
      it 'provides all available semesters' do
        feed = subject.get_feed
        expect(feed[:admin_semesters]).to eq current_terms
      end
    end
  end

  context 'when admin directly specifying CCNs' do
    subject { CanvasLti::CourseProvision.new(uid, admin_by_ccns: by_ccns, admin_term_slug: by_ccns_semester) }
    context 'when a mischiefmaker' do
      let(:uid) { user_id }
      it 'should find nothing useful' do
        feed = subject.get_feed
        expect(feed[:is_admin]).to be_falsey
        expect(feed[:teachingSemesters]).to be_empty
      end
    end
    context 'when a Canvas admin' do
      let(:uid) { canvas_admin_id }
      it 'should find courses' do
        feed = subject.get_feed
        expect(feed[:is_admin]).to be_truthy
        expect(feed[:admin_acting_as]).to be_nil
        expect(feed[:teachingSemesters]).to eq by_ccns_course_list
        expect(feed[:admin_semesters]).to eq current_terms
      end
    end
  end

  describe '#create_course_site' do
    subject     { CanvasLti::CourseProvision.new(instructor_id) }
    let(:cpcs)  { instance_double CanvasCsv::ProvideCourseSite }
    before do
      allow(cpcs).to receive(:background).and_return(cpcs)
      allow(cpcs).to receive(:background_job_save).and_return(true)
      allow(cpcs).to receive(:create_course_site).and_return(true)
      allow(cpcs).to receive(:background_job_id).and_return('canvas.courseprovision.1234.1383330151057')
      allow(CanvasCsv::ProvideCourseSite).to receive(:new).and_return(cpcs)
    end

    it 'returns canvas course provision job id' do
      result = subject.create_course_site('Intro to Biomedicine', 'BIOENG 101 LEC', 'fall-2013', ['1136', '1204'])
      expect(result).to eq 'canvas.courseprovision.1234.1383330151057'
    end

    it 'saves state of job before sending to bg job queue' do
      expect(cpcs).to receive(:background_job_save).ordered.and_return(true)
      expect(cpcs).to receive(:background).ordered.and_return(cpcs)
      expect(cpcs).to receive(:background_job_id).ordered.and_return('canvas.courseprovision.1234.1383330151057')
      subject.create_course_site('Intro to Biomedicine', 'BIOENG 101 LEC', 'fall-2013', ['1136', '1204'])
    end
  end

  describe '#edit_sections' do
    let(:ccns_to_remove) { [random_ccn] }
    let(:ccns_to_add) { [random_ccn] }
    subject { CanvasLti::CourseProvision.new(instructor_id, canvas_course_id: canvas_course_id) }
    context 'when user is authorized' do
      let(:cpcs) { instance_double CanvasCsv::ProvideCourseSite }
      let(:course_info) { {canvasCourseId: canvas_course_id} }
      let(:background_job_id) { "canvas.courseprovision.#{ccns_to_add.first}" }
      before do
        expect(subject).to receive(:get_course_info).and_return(course_info)
        expect(CanvasCsv::ProvideCourseSite).to receive(:new).and_return(cpcs)
        expect(cpcs).to receive(:background_job_save).ordered
        expect(cpcs).to receive(:background).ordered.and_return(cpcs)
        expect(cpcs).to receive(:edit_sections).ordered
        expect(cpcs).to receive(:background_job_id).ordered.and_return(background_job_id)
      end
      it 'saves the state of the job' do
        expect(subject.edit_sections(ccns_to_remove, ccns_to_add)).to eq background_job_id
      end
    end
  end

  describe '#get_course_info' do
    context 'when canvas_course_id not present' do
      subject { CanvasLti::CourseProvision.new(instructor_id) }
      it 'should raise an error' do
        expect { subject.get_course_info }.to raise_error(RuntimeError, 'canvas_course_id option not present')
      end
    end

    context 'when managing sections for existing course site' do
      subject { CanvasLti::CourseProvision.new(instructor_id, canvas_course_id: canvas_course_id) }
      before do
        allow_any_instance_of(Canvas::Course).to receive(:course).and_return(course_hash)
        allow_any_instance_of(Canvas::CourseSections).to receive(:official_section_identifiers).and_return(official_sections)
      end

      it 'should return course information' do
        result = subject.get_course_info
        expect(result).to be_an_instance_of Hash
        expect(result[:canvasCourseId]).to eq canvas_course_id
        expect(result[:name]).to eq course_hash['name']
        expect(result[:courseCode]).to eq course_hash['course_code']
      end

      it 'should return course term' do
        result = subject.get_course_info
        expect(result).to be_an_instance_of Hash
        expect(result[:term]).to be_an_instance_of Hash
        expect(result[:term][:name]).to eq course_hash['term']['name']
        expect(result[:term][:term_yr]).to eq '2013'
        expect(result[:term][:term_cd]).to eq 'D'
      end

      it 'should return official sections' do
        result = subject.get_course_info
        expect(result).to be_an_instance_of Hash
        expect(result[:officialSections]).to eq official_sections
      end
    end
  end

  describe '#find_nonteaching_site_sections' do
    subject { CanvasLti::CourseProvision.new(instructor_id, canvas_course_id: canvas_course_id) }
    it 'should return Canvas section IDs that are not in the list of authorized campus sections' do
      missing_sections = [{term_yr: '2013', term_cd: 'C', ccn: random_ccn}]
      fake_formatter = instance_double(MyAcademics::Teaching)
      expect(fake_formatter).to receive(:courses_list_from_ccns).with('2013', 'C', [missing_sections[0][:ccn]]).and_return(missing_sections)
      allow(MyAcademics::Teaching).to receive(:new).and_return(fake_formatter)
      bigger_site_sections = official_sections + missing_sections
      course_info = {term: {term_yr: '2013', term_cd: 'C'}, officialSections: bigger_site_sections}
      inaccessible = subject.find_nonteaching_site_sections(teaching_semesters, course_info)
      expect(inaccessible).to eq missing_sections
    end
  end

  describe '#merge_non_teaching_site_sections' do
    subject { CanvasLti::CourseProvision.new(instructor_id, canvas_course_id: canvas_course_id) }
    before { subject.merge_non_teaching_site_sections(teaching_semesters, non_teaching_sections) }

    context 'non-teaching section in existing course' do
      let(:non_teaching_sections_list) {[
        {ccn: random_ccn, is_primary_section: true, section_label: 'LEC 001'},
        {ccn: random_ccn, is_primary_section: true, section_label: 'LEC 002'},
        {ccn: random_ccn, is_primary_section: false, section_label: 'DIS 101'},
        {ccn: random_ccn, is_primary_section: false, section_label: 'DIS 103'},
        {ccn: random_ccn, is_primary_section: false, section_label: 'DIS 201'},
        {ccn: random_ccn, is_primary_section: false, section_label: 'LAB 100'},
      ]}

      let(:non_teaching_sections) do
        [{termYear: teaching_semesters.first[:termYear],
          termCode: teaching_semesters.first[:termCode],
          classes: [{
            course_code: teaching_semesters.first[:classes].first[:listings].first[:course_code],
            sections: non_teaching_sections_list.shuffle
          }]
        }]
      end

      it 'adds sections in standard ordering' do
        expect(teaching_semesters.first[:classes].first[:sections]).to eq non_teaching_sections_list.insert(3, teaching_section)
      end
    end

    context 'non-teaching section in different course' do
      let(:non_teaching_courses_list) do
        [
          {listings: [{course_code: 'ANTHRO 999'}, {course_code: 'SANSKRIT 999'}], sections: [{ccn: random_ccn}]},
          {listings: [{course_code: 'ENGIN 2C'}], sections: [{ccn: random_ccn}]},
          {listings: [{course_code: 'ENGIN 99'}], sections: [{ccn: random_ccn}]},
          {listings: [{course_code: 'ENGIN 101L'}], sections: [{ccn: random_ccn}]},
          {listings: [{course_code: 'ENGIN C103'}], sections: [{ccn: random_ccn}]},
          {listings: [{course_code: 'ENGIN C107L'}, {course_code: 'NUCLEARENG C107L'}], sections: [{ccn: random_ccn}]},
          {listings: [{course_code: 'ENGIN 110'}], sections: [{ccn: random_ccn}]},
          {listings: [{course_code: 'ENGIN 110L'}], sections: [{ccn: random_ccn}]},
          {listings: [{course_code: 'ENGIN C112'}], sections: [{ccn: random_ccn}]},
          {listings: [{course_code: 'ENGIN C112L'}], sections: [{ccn: random_ccn}]},
          {listings: [{course_code: 'MCELLBI 10'}], sections: [{ccn: random_ccn}]},
        ]
      end

      let(:non_teaching_sections) do
        [{
          termYear: teaching_semesters.first[:termYear],
          termCode: teaching_semesters.first[:termCode],
          classes: non_teaching_courses_list.shuffle
        }]
      end

      it 'adds courses in standard ordering' do
        expect(teaching_semesters.first[:classes]).to eq non_teaching_courses_list.insert(2, teaching_class)
      end
    end

    context 'non-teaching section in different term' do
      let(:non_teaching_sections) do
        [{termYear: '2014',
            termCode: 'D',
            classes: [
              course_code: 'ENGIN 100',
              sections: [{ccn: random_ccn}]
            ]
          }]
      end

      it 'appends new term' do
        expect(teaching_semesters.last).to eq non_teaching_sections.first
      end
    end
  end

  describe '#group_by_used' do
    # define courses with CCNs in each range
    [
      [:course_1, (25860..25863), 'Course One'],
      [:course_2, (14930..14933), 'Course Two'],
      [:course_3, (23720..23724), 'Course Three'],
      [:course_4, (12420..12422), 'Course Four'],
    ].each do |course_def|
      let(course_def[0]) do
        course = {:title => course_def[2], :sections => []}
        course_def[1].each do |ccn|
          course[:sections] << {:ccn => ccn.to_s}
        end
        course
      end
    end
    let(:teachingSemesters) do
      [
        {
          :name => 'Spring 2015',
          :slug => 'spring-2015',
          :termCode => 'B',
          :termYear => '2015',
          :timeBucket => 'current',
          :gradingInProgress => nil,
          :classes => [course_1, course_2, course_3],
        },
        {
          :name => 'Summer 2015',
          :slug => 'summer-2015',
          :termCode => 'C',
          :termYear => '2015',
          :timeBucket => 'future',
          :gradingInProgress => nil,
          :classes => [course_4],
        }
      ]
    end
    let(:feed) do
      {
        :teachingSemesters => teachingSemesters,
        :canvas_course => {
          :term => {:term_yr => '2015', :term_cd => 'B', :name => 'Spring 2015'},
          :officialSections => [
            {:term_yr=>'2015', :term_cd=>'B', :ccn=>'14932'},
            {:term_yr=>'2015', :term_cd=>'B', :ccn=>'23722'},
            {:term_yr=>'2015', :term_cd=>'B', :ccn=>'23723'},
          ]
        }
      }
    end
    subject { CanvasLti::CourseProvision.new(user_id, canvas_course_id: canvas_course_id) }

    it 'sorts courses with those associated with course site provided first' do
      result = subject.group_by_used!(feed)
      expect(result).to be_an_instance_of Hash
      expect(result[:teachingSemesters]).to be_an_instance_of Array
      expect(result[:teachingSemesters][0]).to be_an_instance_of Hash
      expect(result[:teachingSemesters][1]).to be_an_instance_of Hash
      expect(result[:teachingSemesters][0][:classes]).to be_an_instance_of Array
      expect(result[:teachingSemesters][1][:classes]).to be_an_instance_of Array
      expect(result[:teachingSemesters][0][:classes][0]).to be_an_instance_of Hash
      expect(result[:teachingSemesters][0][:classes][1]).to be_an_instance_of Hash
      expect(result[:teachingSemesters][0][:classes][2]).to be_an_instance_of Hash
      expect(result[:teachingSemesters][1][:classes][0]).to be_an_instance_of Hash
      expect(result[:teachingSemesters][0][:classes][0][:containsCourseSections]).to eq true
      expect(result[:teachingSemesters][0][:classes][1][:containsCourseSections]).to eq true
      expect(result[:teachingSemesters][0][:classes][2][:containsCourseSections]).to eq false
      expect(result[:teachingSemesters][0][:classes][0][:title]).to eq 'Course Two'
      expect(result[:teachingSemesters][0][:classes][1][:title]).to eq 'Course Three'
      expect(result[:teachingSemesters][0][:classes][2][:title]).to eq 'Course One'
      expect(result[:teachingSemesters][1][:classes][0][:title]).to eq 'Course Four'
      expect(result[:teachingSemesters][1][:classes][0][:containsCourseSections]).to eq false
    end

    it 'indicates if sections are in course site within course semester' do
      result = subject.group_by_used!(feed)
      expect(result).to be_an_instance_of Hash
      expect(result[:teachingSemesters]).to be_an_instance_of Array
      expect(result[:teachingSemesters][0]).to be_an_instance_of Hash
      expect(result[:teachingSemesters][1]).to be_an_instance_of Hash
      expect(result[:teachingSemesters][0][:classes]).to be_an_instance_of Array
      expect(result[:teachingSemesters][0][:classes]).to be_an_instance_of Array
      expect(result[:teachingSemesters][0][:classes][0]).to be_an_instance_of Hash
      expect(result[:teachingSemesters][0][:classes][0][:sections]).to be_an_instance_of Array
      expect(result[:teachingSemesters][0][:classes][0][:sections][0]).to be_an_instance_of Hash
      expect(result[:teachingSemesters][0][:classes][0][:sections][0][:isCourseSection]).to eq false
      expect(result[:teachingSemesters][0][:classes][0][:sections][1][:isCourseSection]).to eq false
      expect(result[:teachingSemesters][0][:classes][0][:sections][2][:isCourseSection]).to eq true
      expect(result[:teachingSemesters][0][:classes][0][:sections][3][:isCourseSection]).to eq false
      expect(result[:teachingSemesters][0][:classes][1][:sections][0][:isCourseSection]).to eq false
      expect(result[:teachingSemesters][0][:classes][1][:sections][1][:isCourseSection]).to eq false
      expect(result[:teachingSemesters][0][:classes][1][:sections][2][:isCourseSection]).to eq true
      expect(result[:teachingSemesters][0][:classes][1][:sections][3][:isCourseSection]).to eq true
      expect(result[:teachingSemesters][0][:classes][1][:sections][4][:isCourseSection]).to eq false
    end

    it 'should raise exception if official course section in feed does not match course term' do
      feed[:canvas_course][:officialSections][1][:term_cd] = 'C'
      expect { subject.group_by_used!(feed) }.to raise_error(RuntimeError, 'Invalid term specified for official section with CCN \'23722\'')
    end
  end

end
