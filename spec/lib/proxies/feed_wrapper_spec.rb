describe FeedWrapper do
  subject do
    FeedWrapper.new(MultiXml.parse('
      <Document>
        <Subdocument Initials="abcd">
          <Ajax>a</Ajax>
          <Boris>b</Boris>
          <Charlotte>c</Charlotte>
          <Delphine Alt="porpoise">d</Delphine>
        </Subdocument>
        <Subdocument Initials="efgh">
          <Ernest>e</Ernest>
          <Flora>f</Flora>
          <Gawain>g</Gawain>
          <Hrothgar>h</Hrothgar>
        </Subdocument>
      </Document>
    '))
  end

  context 'wrapping a collection' do
    it 'should wrap key lookups in a new FeedWrapper object' do
      expect(subject['Document']['Subdocument']).to be_a FeedWrapper
    end

    it 'should return a blank object for missing keys' do
      nonsense = subject['Non']['Sense']
      expect(nonsense).to be_a FeedWrapper
      expect(nonsense).to be_blank
    end

    it 'should implement Enumerable methods' do
      expect(
        subject['Document']['Subdocument'].inject('') { |m, i| m + i['Initials'].to_text }
      ).to eq 'abcdefgh'
    end

    context 'finding by key and value' do
      it 'should find elements by key and value' do
        expect(subject['Document']['Subdocument'].find_by('Initials', 'efgh')).to be_a FeedWrapper
      end

      it 'should return blank on failed finds' do
        failed = subject['Document']['Subdocument'].find_by('Initials', 'wxyz')
        expect(failed).to be_a FeedWrapper
        expect(failed).to be_blank
      end
    end
  end

  context 'wrapping a String' do
    let(:text_wrapper) { FeedWrapper.new('text    ') }
    let(:date_wrapper) { FeedWrapper.new('3rd Feb 2001    ') }
    let(:time_wrapper) { FeedWrapper.new(923) }

    it 'should strip string on coercion' do
      expect(text_wrapper.to_text).to eq 'text'
    end

    it 'should return blank on key lookups' do
      expect(text_wrapper[1]).to be_a FeedWrapper
      expect(text_wrapper[1]).to be_blank
    end

    it 'should parse date strings' do
      date = date_wrapper.to_date
      expect(date.year).to eq 2001
      expect(date.mon).to eq 2
      expect(date.mday).to eq 3
    end

    it 'should format time strings' do
      expect(time_wrapper.to_time).to eq '9:23'
    end

    it 'should return blank on unparseable dates or times' do
      expect(text_wrapper.to_date).to eq ''
      expect(text_wrapper.to_time).to eq ''
    end
  end

  context 'wrapping blank' do
    let(:blankwrapper) { FeedWrapper.new(nil) }

    it 'should return blank or default on key lookups' do
      expect(blankwrapper[1]).to be_a FeedWrapper
      expect(blankwrapper[1]).to be_blank
    end

    it 'should return blank objects on coercion' do
      expect(blankwrapper.to_text).to eq ''
      expect(blankwrapper.to_a).to eq []
    end

    it 'should accept a default argument on coercion' do
      expect(blankwrapper.to_text('Default')).to eq 'Default'
    end
  end

  context 'as collection' do
    it 'should wrap a non-Array in an Array' do
      expect(subject['Document'].as_collection.unwrap).to eq [ subject['Document'].unwrap ]
    end

    it 'should not wrap an Array in another Array' do
      expect(subject['Document']['Subdocument'].as_collection.unwrap).to eq subject['Document']['Subdocument'].unwrap
    end
  end

end
