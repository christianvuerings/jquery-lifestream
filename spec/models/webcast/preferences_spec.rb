describe Webcast::Preferences do

  describe '#lookup' do
    before do
      Webcast::Preferences.create(
        {
          year: 2015,
          term_cd: 'D',
          ccn: 1234,
          opt_out: true})
      Webcast::Preferences.create(
        {
          year: 2016,
          term_cd: 'B',
          ccn: 5678,
          opt_out: false})
    end

    it 'should deny per uniqueness constraint' do
      expect {
        Webcast::Preferences.create(
          {
            year: 2016,
            term_cd: 'B',
            ccn: 5678,
            opt_out: true})
      }.to raise_error NameError
    end

    it 'should not find matching record' do
      expect(Webcast::Preferences.lookup(2015, 'B', 1234)).to be_nil
    end

    it 'should return record with opt_out equal false' do
      record = Webcast::Preferences.lookup(2015, 'D', 1234)
      expect(record).to_not be_nil
      expect(record.opt_out).to be true
    end
  end
end
