describe MyAcademics::Semesters do

  let(:feed) { feed = {}; MyAcademics::Semesters.new(random_id).merge(feed); feed }

  before do
    allow_any_instance_of(CampusOracle::UserCourses::All).to receive(:get_all_campus_courses).and_return enrollment_data
    allow_any_instance_of(CampusOracle::UserCourses::Transcripts).to receive(:get_all_transcripts).and_return transcript_data
  end

  let(:term_keys) { ['2013-B', '2013-D', '2014-B', '2014-C'] }
  let(:enrollment_data) { Hash[term_keys.map{|key| [key, enrollment_term(key)]}] }
  let(:transcript_data) do
    {
      semesters: Hash[term_keys.map{|key| [key, transcript_term(key)]}],
      additional_credits: rand(3..6).times.map { additional_credit }
    }
  end

  def enrollment_term(key)
    rand(2..4).times.map { course_enrollment(key) }
  end

  def transcript_term(key)
    {
      courses: enrollment_data[key].map { |e| course_transcript_matching_enrollment(e) },
      notations: []
    }
  end

  def course_enrollment(term_key)
    term_yr, term_cd = term_key.split('-')
    dept = random_string(5)
    catid = rand(999).to_s
    {
      id: "#{dept}-#{catid}-#{term_key}",
      slug: "#{dept}-#{catid}",
      course_code: "#{dept.upcase} #{catid}",
      term_yr: term_yr,
      term_cd: term_cd,
      dept: dept.upcase,
      dept_desc: dept,
      catid: catid,
      course_catalog: catid,
      course_option: 'A1',
      emitter: 'Campus',
      name: random_string(15).capitalize,
      sections: course_enrollment_sections,
      role: 'Student'
    }
  end

  def course_enrollment_sections
    sections = [ course_enrollment_section(is_primary_section: true) ]
    rand(1..3).times { sections << course_enrollment_section(is_primary_section: false) }
    sections
  end

  def course_enrollment_section(opts={})
    format = opts[:format] || ['LEC', 'DIS', 'SEM'].sample
    section_number = opts[:section_number] || "00#{rand(9)}"
    is_primary_section = opts[:is_primary_section] || false
    {
      ccn: random_ccn,
      instruction_format: format,
      is_primary_section: is_primary_section,
      section_label: "#{format} #{section_number}",
      section_number: section_number,
      units: (is_primary_section ? rand(1.0..5.0).round(1) : 0.0),
      pnp_flag: 'N ',
      cred_cd: nil,
      grade: (is_primary_section ? random_grade : nil),
      cross_listed_flag: nil,
      schedules: [{
        buildingName: random_string(10),
        roomNumber: rand(9).to_s,
        schedule: 'MWF 11:00A-12:00P'
      }],
      instructors: [{name: random_name, uid: random_id}]
    }
  end

  def course_transcript_matching_enrollment(enrollment)
    {
      dept: enrollment[:dept],
      courseCatalog: enrollment[:catid],
      title: enrollment[:name].upcase,
      units: rand(1.0..5.0).round(1),
      grade: random_grade
    }
  end

  def additional_credit
    {
      title: "AP #{random_string(8).upcase}",
      units: rand(1.0..5.0).round(1),
    }
  end

  it 'should include the expected semesters in reverse order' do
    expect(feed[:semesters].length).to eq 4
    term_keys.sort.reverse.each_with_index do |key, index|
      term_year, term_code = key.split('-')
      expect(feed[:semesters][index]).to include({
        termCode: term_code,
        termYear: term_year,
        name: Berkeley::TermCodes.to_english(term_year, term_code)
      })
    end
  end

  it 'should place semesters in the right buckets' do
    current_term = Berkeley::Terms.fetch.current
    current_term_key = "#{current_term.year}-#{current_term.code}"
    feed[:semesters].each do |s|
      semester_key = "#{s[:termYear]}-#{s[:termCode]}"
      if semester_key < current_term_key
        expect(s[:timeBucket]).to eq 'past'
      elsif semester_key > current_term_key
        expect(s[:timeBucket]).to eq 'future'
      else
        expect(s[:timeBucket]).to eq 'current'
      end
    end
  end

  it 'should preserve structure of enrollment data' do
    feed[:semesters].each do |s|
      expect(s[:hasEnrollmentData]).to eq true
      enrollment_semester = enrollment_data["#{s[:termYear]}-#{s[:termCode]}"]
      expect(s[:classes].length).to eq enrollment_semester.length
      s[:classes].each do |course|
        matching_enrollment = enrollment_semester.find { |e| e[:id] == course[:course_id] }
        expect(course[:sections].count).to eq matching_enrollment[:sections].count
        expect(course[:title]).to eq matching_enrollment[:name]
        expect(course[:courseCatalog]).to eq matching_enrollment[:course_catalog]
        expect(course[:url]).to include matching_enrollment[:slug]
        [:course_code, :dept, :dept_desc, :role, :slug].each do |key|
          expect(course[key]).to eq matching_enrollment[key]
        end
      end
    end
  end

  context 'multiple primaries' do
    let(:multiple_primary_enrollment_term) do
      term = enrollment_term('2013-D')
      term.first[:course_option] = 'E1'
      term.first[:sections] = [
        course_enrollment_section(is_primary_section: true, format: 'LEC', section_number: '001'),
        course_enrollment_section(is_primary_section: true, format: 'LEC', section_number: '002'),
        course_enrollment_section(is_primary_section: false, format: 'DIS', section_number: '101'),
        course_enrollment_section(is_primary_section: false, format: 'DIS', section_number: '201')
      ]
      term
    end
    let(:term_keys) { ['2013-D'] }
    let(:enrollment_data) { {'2013-D' => multiple_primary_enrollment_term} }

    let(:classes) { feed[:semesters].first[:classes] }
    let(:multiple_primary_class) { classes.first }
    let(:single_primary_classes) { classes[1..-1] }

    it 'should flag multiple primaries' do
      expect(multiple_primary_class[:multiplePrimaries]).to eq true
      single_primary_classes.each { |c| expect(c).not_to include(:multiplePrimaries) }
    end

    it 'should include slugs and URLs only for primary sections of multiple-primary courses' do
      multiple_primary_class[:sections].each do |s|
        if s[:is_primary_section]
          expect(s[:slug]).to eq "#{s[:instruction_format].downcase}-#{s[:section_number]}"
          expect(s[:url]).to eq "#{multiple_primary_class[:url]}/#{s[:slug]}"
        else
          expect(s).not_to include(:slug)
          expect(s).not_to include(:url)
        end
      end
      single_primary_classes.each do |c|
        c[:sections].each do |s|
          expect(s).not_to include(:slug)
          expect(s).not_to include(:url)
        end
      end
    end

    it 'should associate secondary sections with the correct primaries' do
      expect(multiple_primary_class[:sections][0]).not_to include(:associatedWithPrimary)
      expect(multiple_primary_class[:sections][1]).not_to include(:associatedWithPrimary)
      expect(multiple_primary_class[:sections][2][:associatedWithPrimary]).to eq multiple_primary_class[:sections][0][:slug]
      expect(multiple_primary_class[:sections][3][:associatedWithPrimary]).to eq multiple_primary_class[:sections][1][:slug]
    end
  end

  it 'should include additional credits' do
    expect(feed[:additionalCredits]).to eq transcript_data[:additional_credits]
  end

  context 'when enrollment data for a term is unavailable' do
    let(:term_yr) { '2013' }
    let(:term_cd) { 'D' }
    let(:feed_semester) { feed[:semesters].find { |s| s[:name] == Berkeley::TermCodes.to_english(term_yr, term_cd) } }
    let(:transcript_semester) { transcript_data[:semesters]["#{term_yr}-#{term_cd}"] }

    let(:sparse_enrollment_data) { enrollment_data.except "#{term_yr}-#{term_cd}" }
    before { allow_any_instance_of(CampusOracle::UserCourses::All).to receive(:get_all_campus_courses).and_return sparse_enrollment_data }

    it 'should include transcript data' do
      expect(feed_semester[:hasEnrollmentData]).to eq false
      expect(feed_semester[:classes].length).to eq transcript_semester[:courses].length
      feed_semester[:classes].each do |course|
        transcript_match = transcript_semester[:courses].find { |c| c[:title] == course[:title] }
        expect(course[:courseCatalog]).to eq transcript_match[:courseCatalog]
        expect(course[:dept]).to eq transcript_match[:dept]
        expect(course[:courseCatalog]).to eq transcript_match[:courseCatalog]
        expect(course[:course_code]).to eq "#{transcript_match[:dept]} #{transcript_match[:courseCatalog]}"
        expect(course[:sections]).to eq []
        expect(course[:transcript]).to eq [{
                units: transcript_match[:units],
                grade: transcript_match[:grade]
              }]
      end
    end

    it 'should translate extension notations' do
      transcript_semester[:notations] << 'extension'
      expect(feed_semester[:notation]).to eq 'UC Extension'
    end

    it 'should translate education abroad notations' do
      transcript_semester[:notations] << 'abroad'
      expect(feed_semester[:notation]).to eq 'Education Abroad'
    end

    it 'should not insert notation when none provided' do
      expect(feed_semester[:notation]).to be_nil
    end
  end

  describe 'merging grade data' do
    before { allow(Settings.terms).to receive(:fake_now).and_return(fake_now) }

    let(:term_yr) { '2013' }
    let(:term_cd) { 'D' }
    let(:feed_semester) { feed[:semesters].find { |s| s[:name] == Berkeley::TermCodes.to_english(term_yr, term_cd) } }
    let(:feed_semester_grades) { feed_semester[:classes].map { |course| course[:transcript] } }

    shared_examples 'grades from enrollment' do
      it 'returns enrollment grades' do
        grades_from_enrollment = enrollment_data["#{term_yr}-#{term_cd}"].map { |e| e[:sections].map{ |s| s.slice(:units, :grade) if s[:is_primary_section] }.compact }
        expect(feed_semester_grades).to match_array grades_from_enrollment
      end
    end

    shared_examples 'grades from transcript' do
      it 'returns transcript grades' do
        grades_from_transcript = transcript_data[:semesters]["#{term_yr}-#{term_cd}"][:courses].map { |t| [ t.slice(:units, :grade) ] }
        expect(feed_semester_grades).to match_array grades_from_transcript
      end
    end

    shared_examples 'grading in progress' do
      it { expect(feed_semester[:gradingInProgress]).to be_truthy }
    end

    shared_examples 'grading not in progress' do
      it { expect(feed_semester[:gradingInProgress]).to be_nil }
    end

    context 'current semester' do
      let(:fake_now) {DateTime.parse('2013-10-10')}
      include_examples 'grades from enrollment'
      include_examples 'grading not in progress'
    end

    context 'semester just ended' do
      let(:fake_now) {DateTime.parse('2013-12-30')}
      include_examples 'grades from enrollment'
      include_examples 'grading in progress'
    end

    context 'past semester' do
      let(:fake_now) {DateTime.parse('2014-01-20')}
      include_examples 'grades from transcript'
      include_examples 'grading not in progress'
    end
  end

end
