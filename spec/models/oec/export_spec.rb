describe Oec::Export do

  describe '#configure' do
    context 'setting export directory' do
      tmp_dir = 'tmp/oec'
      subject { Oec::Export.new tmp_dir }
      it {
        subject.export_directory.should eq tmp_dir
      }
    end
  end

end
