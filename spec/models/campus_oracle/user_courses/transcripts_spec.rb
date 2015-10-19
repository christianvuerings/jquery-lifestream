describe CampusOracle::UserCourses::Transcripts do
  let (:transcripts) { CampusOracle::UserCourses::Transcripts.new(user_id: random_id).get_all_transcripts }

  def random_term_year
    ('2012'..'2015').to_a.sample
  end

  def random_term_code
    ('B'..'D').to_a.sample
  end

  def transcript_row
    {
      'term_yr' => random_term_year,
      'term_cd' => random_term_code,
      'dept_name' => 'BIOLOGY',
      'catalog_id' => random_id,
      'grade' => random_grade,
      'transcript_unit' => rand(1.0..5.0).round(1),
      'transfer_unit' => 0,
      'line_type' => 'U',
      'memo_or_title' => 'INTRO TO BIOLOGY'
    }
  end

  let (:blank_transcript_row) do
    {
      'term_yr' => '',
      'term_cd' => '',
      'dept_name' => '',
      'catalog_id' => '',
      'grade' => '',
      'transcript_unit' => 0,
      'transfer_unit' => 0,
      'line_type' => '',
      'memo_or_title' => ''
    }
  end

  let (:transcript_data) { 10.times.map { transcript_row } }
  before { allow(CampusOracle::Queries).to receive(:get_transcript_grades).and_return(transcript_data) }

  it 'correctly formats term keys' do
    transcripts[:semesters].each do |term_key, data|
      expect(term_key).to match /\A201\d-[BCD]\Z/
    end
  end

  it 'includes expected course data' do
    transcripts[:semesters].each do |term_key, data|
      data[:courses].each do |course|
        [:dept, :courseCatalog, :title, :units, :grade].each { |key| expect(course[key]).to be_present }
      end
    end
  end

  it 'includes as many courses as provided transcript rows' do
    expect(transcripts[:semesters].collect{ |term_key, data| data[:courses] }.flatten.count).to eq transcript_data.count
  end

  context 'when transcript data includes zero-unit notations' do
    let (:transcript_data) do
      data = 10.times.map { transcript_row }
      data << transcript_row.merge('transcript_unit' => 0.0)
    end

    it 'excludes them' do
      transcripts[:semesters].each do |term_key, data|
        expect(data[:courses].select { |c| c[:units].zero? }).to be_empty
      end
    end
  end

  context 'when transcript data includes REMOVED and LAPSED notations' do
    let (:transcript_data) do
      data = 10.times.map { transcript_row }
      data << transcript_row.merge('memo_or_title' => '***REMOVED***')
      data << transcript_row.merge('memo_or_title' => '***LAPSED***')
    end

    it 'excludes them' do
      transcripts[:semesters].each do |term_key, data|
        expect(data[:courses].select { |c| c[:title].include? 'REMOVED'}).to be_empty
        expect(data[:courses].select { |c| c[:title].include? 'LAPSED'}).to be_empty
      end
    end
  end

  context 'when transcript data includes AP credits with no term' do
    let (:ap_unit_count) { 5.3 }
    let (:ap_course_title) { 'ADV PLACEMEN' + random_string(10).upcase }
    let (:transcript_data) do
      data = 10.times.map { transcript_row }
      data << blank_transcript_row.merge({
          'term_yr' => '0',
          'transcript_unit' => ap_unit_count,
          'line_type' => 'A',
          'memo_or_title' => ap_course_title
        })
    end

    it 'includes them as additional credits' do
      expect(transcripts[:additional_credits].count).to eq 1
      expect(transcripts[:additional_credits][0][:units]).to eq ap_unit_count
      expect(transcripts[:additional_credits][0][:title]).to eq ap_course_title.sub('ADV PLACEMEN', 'AP ')
    end
  end

  context 'when transcript data includes transfer credits' do
    let (:transfers) { [{units: 16, memo: 'HAHVAHD UNIV EXTENSION'}, {units: 79, memo: 'EL CERRITO COL, 11 TRM SP02-FA07'}] }
    let (:transcript_data) do
      data = 10.times.map { transcript_row }
      transfers.each do |transfer|
        data << blank_transcript_row.merge({
            'term_yr' => '0',
            'transcript_unit' => 0,
            'transfer_unit' => 0,
            'line_type' => 'J',
            'memo_or_title' => transfer[:memo]
          })
        data << blank_transcript_row.merge({
            'term_yr' => '0',
            'transcript_unit' => 0,
            'transfer_unit' => transfer[:units],
            'line_type' => 'J',
            'memo_or_title' => ''
          })
      end
      data
    end

    it 'includes them as additional credits' do
      expect(transcripts[:additional_credits].count).to eq 2
      transfers.each_index do |i|
        expect(transcripts[:additional_credits][i][:units]).to eq transfers[i][:units]
        expect(transcripts[:additional_credits][i][:title]).to eq transfers[i][:memo]
      end
    end
  end

  context 'when transcript data includes extramural notations' do
    let (:abroad_term) { {'term_yr' => random_term_year, 'term_cd' => random_term_code} }
    let (:extension_term) { {'term_yr' => random_term_year, 'term_cd' => random_term_code} }
    let (:exchange_term) { {'term_yr' => random_term_year, 'term_cd' => random_term_code} }

    let(:transcript_data) do
      data = 10.times.map { transcript_row }
      data << blank_transcript_row.merge(abroad_term).merge('line_type' => 'V', 'memo_or_title' => 'EDUCATION ABROAD -')
      3.times { data << transcript_row.merge(abroad_term) }
      data << blank_transcript_row.merge(extension_term).merge('line_type' => 'V', 'memo_or_title' => 'UC EXTENSION')
      3.times { data << transcript_row.merge(extension_term) }
      data
    end

    it 'identifies ABROAD notation' do
      expect(transcripts[:semesters]["#{abroad_term['term_yr']}-#{abroad_term['term_cd']}"][:notations]).to include 'abroad'
    end

    it 'identifies EXTENSION notation' do
      expect(transcripts[:semesters]["#{extension_term['term_yr']}-#{extension_term['term_cd']}"][:notations]).to include 'extension'
    end
  end
end
