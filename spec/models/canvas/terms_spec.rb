describe Canvas::Terms do
  subject { Canvas::Terms.fetch }

  it {should be_a Array}
  it {should_not be_empty}

  it 'should return terms as hashes with id, name, and (unless default term) SIS ID' do
    subject.each do |term|
      expect(term).to be_a Hash
      expect(term['id']).to be_a Integer
      expect(term['name']).to be_a String
      unless term['name'] == 'Default Term'
        expect(term['sis_term_id']).to be_a String
        expect(term['sis_term_id']).to match(/\A(TERM:)?\d{4}\-[A-Z]+\Z/)
      end
    end
  end

  context 'when converting sis section ids to term and ccn' do
    it 'should return term and ccn' do
      result = Canvas::Terms.sis_section_id_to_ccn_and_term('SEC:2014-B-25573')
      expect(result[:term_yr]).to eq '2014'
      expect(result[:term_cd]).to eq 'B'
      expect(result[:ccn]).to eq '25573'
    end
    it 'is not confused by leading zeroes' do
      result_plain = Canvas::Terms.sis_section_id_to_ccn_and_term('SEC:2014-B-1234')
      result_fancy = Canvas::Terms.sis_section_id_to_ccn_and_term('SEC:2014-B-01234')
      expect(result_fancy).to eq result_plain
    end
  end

  describe '#current_terms' do
    before { allow(Settings.terms).to receive(:fake_now).and_return(fake_now) }
    subject {Canvas::Terms.current_terms}
    context 'during the Fall term' do
      let(:fake_now) {DateTime.parse('2013-10-10')}
      its(:length) {should eq 2}
      it 'includes next term and this term' do
        expect(subject[0].slug).to eq 'fall-2013'
        expect(subject[1].slug).to eq 'spring-2014'
      end
    end
    context 'between terms' do
      let(:fake_now) {DateTime.parse('2013-09-20')}
      its(:length) {should eq 2}
      it 'includes the next two terms' do
        expect(subject[0].slug).to eq 'fall-2013'
        expect(subject[1].slug).to eq 'spring-2014'
      end
    end
    context 'during the Spring term' do
      let(:fake_now) {DateTime.parse('2014-02-10')}
      its(:length) {should eq 3}
      it 'includes next Fall term if available' do
        expect(subject[0].slug).to eq 'spring-2014'
        expect(subject[1].slug).to eq 'summer-2014'
        expect(subject[2].slug).to eq 'fall-2014'
      end
    end
    context 'when a campus term is not defined in Canvas' do
      before do
        stub_terms = [
          {'end_at'=>nil,
            'id'=>1818,
            'name'=>'Default Term',
            'start_at'=>nil,
            'workflow_state'=>'active',
            'sis_term_id'=>nil},
          {'end_at'=>nil,
            'id'=>5168,
            'name'=>'Spring 2014',
            'start_at'=>nil,
            'workflow_state'=>'active',
            'sis_term_id'=>'TERM:2014-B'},
          {'end_at'=>nil,
            'id'=>5266,
            'name'=>'Summer 2014',
            'start_at'=>nil,
            'workflow_state'=>'active',
            'sis_term_id'=>'TERM:2014-C'}
        ]
        allow(Canvas::Terms).to receive(:fetch).and_return(stub_terms)
      end
      let(:fake_now) {DateTime.parse('2014-02-10')}
      it 'does not include the campus term undefined in Canvas' do
        expect(subject.select{|term| term.slug == 'fall-2014'}).to be_empty
      end
    end
  end
end
