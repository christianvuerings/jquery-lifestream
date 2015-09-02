include OecSpecHelper

describe Oec::TermSetupTask do

  let(:term_code) { '2015-D' }
  subject { described_class.new(term_code: term_code) }

  let(:fake_sheets_manager) { double() }
  before { allow(GoogleApps::SheetsManager).to receive(:new).and_return fake_sheets_manager }

  let(:today) { '2015-08-31' }
  let(:now) { '092222' }
  let(:logfile) { "#{now}_term_setup_task.log" }
  before { allow(DateTime).to receive(:now).and_return DateTime.strptime("#{today} #{now}", '%F %H%M%S') }

  shared_context 'expecting folder creation' do
    before do
      expect_folder_creation(term_code, 'root', read_after_creation: true)
      %w(departments exports imports supplemental_sources).each do |folder_name|
        expect_folder_creation(folder_name, term_code)
      end
    end
  end

  shared_context 'expecting logging' do
    before do
      expect_folder_creation('reports', term_code, read_after_creation: true)
      expect_folder_creation(today, 'reports')
      expect(fake_sheets_manager).to receive(:find_items_by_title)
        .with(logfile, parent_id: mock_file(today).id)
        .and_return []
      expect(fake_sheets_manager).to receive(:upload_file)
        .with(logfile, '', mock_file(today).id, 'text/plain', Rails.root.join('tmp', 'oec', logfile).to_s)
        .and_return mock_file(logfile)
    end
  end

  context 'when no previous term data is found in remote drive' do
    include_context 'expecting folder creation'
    include_context 'expecting logging'

    before { allow(fake_sheets_manager).to receive(:find_folders).with(no_args).and_return [] }

    it 'checks CSV existence and uploads header-only CSVs as supplemental sources' do
      %w(course_instructors.csv course_supervisors.csv courses.csv instructors.csv supervisors.csv).each do |csv_name|
        expect_sheet_upload(csv_name, 'supplemental_sources')
      end
      subject.run
    end

    context 'when existing files would be overwritten' do
      before do
        %w(course_instructors course_supervisors courses instructors supervisors).each do |sheet_name|
          allow(fake_sheets_manager).to receive(:find_items_by_title)
            .with(sheet_name, parent_id: mock_file('supplemental_sources').id)
            .and_return [mock_file(sheet_name)]
          end
      end
      it 'aborts the task and logs error' do
        expect(Rails.logger).to receive(:error) do |error_message|
          expect(error_message.lines.first).to match /Oec::TermSetupTask aborted with error.*already exists.*could not upload/
        end
        subject.run
      end
    end
  end

  context 'when previous term data is found in remote drive' do
    include_context 'expecting folder creation'
    include_context 'expecting logging'

    before do
      @mock_existing_csvs = {}
      %w(course_supervisors instructors supervisors).each do |sheet_name|
        @mock_existing_csvs[sheet_name] = mock_file(sheet_name)
      end
      expect(fake_sheets_manager).to receive(:find_folders).with(no_args).and_return [mock_file('2015-B'), mock_file('2015-C')]
      %w(supplemental_sources exports).each do |folder_name|
        expect(fake_sheets_manager).to receive(:find_folders_by_title)
          .with(folder_name, mock_file('2015-C').id)
          .and_return [mock_file(folder_name)]
      end
      expect(fake_sheets_manager).to receive(:find_folders)
        .with(mock_file('exports').id)
        .and_return [mock_file('2015-06-04'), mock_file('2015-06-22')]
      expect(fake_sheets_manager).to receive(:find_items_by_title)
        .with('course_supervisors', parent_id: mock_file('2015-06-22').id)
        .and_return [@mock_existing_csvs['course_supervisors']]
    end

    it 'copies existing files and uploads others' do
      %w(instructors supervisors).each do |csv_name|
        expect(fake_sheets_manager).to receive(:find_items_by_title)
          .with(csv_name, parent_id: mock_file('supplemental_sources').id)
          .at_least(2).times
          .and_return([@mock_existing_csvs[csv_name]], [])
        expect(fake_sheets_manager).to receive(:copy_item_to_folder)
          .with(@mock_existing_csvs[csv_name], mock_file('supplemental_sources').id)
          .and_return @mock_existing_csvs[csv_name]
      end
      expect(fake_sheets_manager).to receive(:find_items_by_title)
        .with('course_supervisors', parent_id: mock_file('supplemental_sources').id)
        .and_return []
      expect(fake_sheets_manager).to receive(:copy_item_to_folder)
        .with(@mock_existing_csvs['course_supervisors'], mock_file('supplemental_sources').id)
        .and_return @mock_existing_csvs['course_supervisors']
      %w(course_instructors.csv courses.csv).each do |csv_name|
        expect_sheet_upload(csv_name, 'supplemental_sources')
      end
      subject.run
    end
  end

  context 'Google Drive connection error' do
    before do
      expect(fake_sheets_manager).to receive(:find_folders_by_title)
        .at_least(1).times
        .and_raise Errors::ProxyError, 'A confounding error'
    end
    it 'logs errors' do
      expect(Rails.logger).to receive(:error).at_least(1).times do |error_message|
        expect(error_message.lines.first).to include 'A confounding error'
      end
      subject.run
    end
  end

  context 'local-write mode' do
    subject { described_class.new(term_code: term_code, local_write: 'Y') }

    it 'reads from but does not write to remote drive' do
      expect(fake_sheets_manager).to receive(:find_folders).with(no_args).and_return []
      expect(fake_sheets_manager).not_to receive(:upload_file)
      subject.run
    end
  end
end
