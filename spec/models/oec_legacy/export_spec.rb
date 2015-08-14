describe OecLegacy::Export do

  let!(:export_dir) { '/var/tmp/oec' }
  let!(:base_file_name) { 'filename' }
  let!(:exporter) { ExportStub.new(export_dir, base_file_name) }
  let!(:expected_output_path) { '/var/tmp/oec/filename.csv' }
  let!(:mock_output) { Object.new }

  before do
    allow(mock_output).to receive(:close)
  end

  it 'should construct proper directory paths' do
    exporter.output_filename.should eq expected_output_path
  end

  it 'should create new file per flag' do
    expect(CSV).to receive(:open).with(expected_output_path, 'wb', anything).once.and_return mock_output
    exporter.export true
  end

  it 'should append to existing file per flag' do
    expect(CSV).to receive(:open).with(expected_output_path, 'a', anything).once.and_return mock_output
    exporter.export false
  end

  class ExportStub < OecLegacy::Export
    def initialize(export_dir, base_file_name)
      super export_dir
      @base_file_name = base_file_name
    end

    def base_file_name
      @base_file_name
    end
  end

end
