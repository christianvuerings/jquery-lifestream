describe CanvasLti::OfficialCourse do
  let(:canvas_course_id) { rand(99999).to_s }
  subject { CanvasLti::OfficialCourse.new(:canvas_course_id => canvas_course_id) }

  context 'when providing official section identifiers existing within course' do
    let(:success_response) { [{:term_yr => '2014', :term_cd => 'C', :ccn => '7309'}, {:term_yr => '2014', :term_cd => 'C', :ccn => '6211'}] }
    context 'when official sections returned' do
      it 'returns course sections if already obtained' do
        expect_any_instance_of(Canvas::CourseSections).to receive(:official_section_identifiers).once.and_return(success_response)
        result_1 = subject.official_section_identifiers
        expect(result_1).to be_an_instance_of Array
        expect(result_1.count).to eq 2
        expect(result_1[0]).to eq({:term_yr => '2014', :term_cd => 'C', :ccn => '7309'})
        expect(result_1[1]).to eq({:term_yr => '2014', :term_cd => 'C', :ccn => '6211'})

        result_2 = subject.official_section_identifiers
        expect(result_2).to be_an_instance_of Array
        expect(result_2.count).to eq 2
        expect(result_2[0]).to eq({:term_yr => '2014', :term_cd => 'C', :ccn => '7309'})
        expect(result_2[1]).to eq({:term_yr => '2014', :term_cd => 'C', :ccn => '6211'})
      end
    end
  end

  context 'when providing official section terms existing within course' do
    let(:section_identifiers) {[
      {:term_yr => '2014', :term_cd => 'C', :ccn => '1298', :name => 'LAW 2081 LEC 002'},
      {:term_yr => '2014', :term_cd => 'C', :ccn => '1299', :name => 'LAW 2081 LEC 001'},
      {:term_yr => '2014', :term_cd => 'D', :ccn => '1028', :name => 'LAW 2081 DIS 101'}
    ]}
    before { allow(subject).to receive(:official_section_identifiers).and_return(section_identifiers) }
    it 'it returns array of term hashes' do
      # Note: There should never be more than one term in a course site
      # This feature is intended for detecting an exceptional scenario
      result = subject.section_terms
      expect(result).to be_an_instance_of Array
      expect(result.count).to eq 2
      expect(result[0]).to be_an_instance_of Hash
      expect(result[1]).to be_an_instance_of Hash
      expect(result[0][:term_cd]).to eq 'C'
      expect(result[1][:term_cd]).to eq 'D'
      expect(result[0][:term_yr]).to eq '2014'
      expect(result[1][:term_yr]).to eq '2014'
    end
  end

  context 'when indicating if a course site has official sections' do
    let(:section_identifiers) {
      [
        {:term_yr => '2014', :term_cd => 'C', :ccn => '7309'},
        {:term_yr => '2014', :term_cd => 'C', :ccn => '6211'},
      ]
    }
    before { allow(subject).to receive(:official_section_identifiers).and_return(section_identifiers) }

    it "uses cache by default" do
      expect(CanvasLti::OfficialCourse).to receive(:fetch_from_cache).with("is-official-#{canvas_course_id}").and_return(false)
      result = subject.is_official_course?
      expect(result).to eq false
    end

    it 'bypasses cache when cache option is false' do
      expect(CanvasLti::OfficialCourse).to_not receive(:fetch_from_cache).with("is-official-#{canvas_course_id}")
      result = subject.is_official_course?(:cache => false)
      expect(result).to eq true
    end

    it 'returns true when course site has official sections' do
      expect(subject.is_official_course?).to eq true
    end

    it 'returns false when course site does not contain official sections' do
      expect(subject).to receive(:official_section_identifiers).and_return([])
      expect(subject.is_official_course?).to eq false
    end
  end

end
