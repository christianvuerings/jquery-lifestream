describe Webcast::Preferences do

  describe '#lookup' do
    before do
      Webcast::Preferences.create params(2015, 'D', 1234, true)
      Webcast::Preferences.create params(2016, 'B', 5678, false)
    end

    it 'should deny per uniqueness constraint' do
      expect { Webcast::Preferences.create params(2016, 'B', 5678, true) }.to raise_exception
    end

    it 'should not find matching record' do
      expect(Webcast::Preferences.find_by({ year: 2015, term_cd: 'B', ccn: 1234 })).to be_nil
    end

    it 'should return record with opt_out equal false' do
      record = Webcast::Preferences.find_by({ year: 2015, term_cd: 'D', ccn: 1234 })
      expect(record).to_not be_nil
      expect(record.year).to eq 2015
      expect(record.term_cd).to eq 'D'
      expect(record.ccn).to eq 1234
      expect(record.opt_out).to be true
    end
  end

  private

  def params(year, term_cd, ccn, opt_out)
    { year: year, term_cd: term_cd, ccn: ccn, opt_out: opt_out }
  end

end
