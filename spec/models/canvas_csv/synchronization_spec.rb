describe CanvasCsv::Synchronization do
  before { CanvasCsv::Synchronization.create(last_guest_user_sync: 1.weeks.ago.utc) }

  describe '.get' do
    it 'raises exception if no record exists' do
      CanvasCsv::Synchronization.delete_all
      expect(CanvasCsv::Synchronization.count).to eq 0
      expect { CanvasCsv::Synchronization.get }.to raise_error(RuntimeError, 'Canvas synchronization data is missing')
    end

    it 'returns primary synchronization record' do
      result = CanvasCsv::Synchronization.get
      expect(result).to be_an_instance_of CanvasCsv::Synchronization
      expect(result.last_guest_user_sync).to be_an_instance_of ActiveSupport::TimeWithZone
    end
  end
end
