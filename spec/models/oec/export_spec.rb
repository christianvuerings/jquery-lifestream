describe Oec::Export do

  describe '#load_settings' do
    context 'building path to export directory' do
      subject { Oec::Export.new }
      it {
        term = Settings.oec.current_terms_codes[0]
        today = DateTime.now.strftime('%F')
        subject.export_directory.should eq "tmp/oec/data/#{term.year}-#{term.code}/raw/#{today}"
      }
    end
  end

end
