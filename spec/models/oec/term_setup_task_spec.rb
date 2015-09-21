describe Oec::TermSetupTask do

  let(:term_code) { 'fake_term' }
  let(:today) { '2015-08-31' }
  let(:now) { '09:22:22' }
  let(:logfile) { "#{now} term setup task.log" }
  before { allow(DateTime).to receive(:now).and_return DateTime.strptime("#{today} #{now}", '%F %H:%M:%S') }

  subject { described_class.new(term_code: term_code) }

  let (:fake_remote_drive) { double() }
  before { allow(Oec::RemoteDrive).to receive(:new).and_return fake_remote_drive }

  context 'successful term setup' do
    before(:each) do
      allow(fake_remote_drive).to receive(:find_nested).and_return mock_google_drive_item
    end

    let(:term_folder) { mock_google_drive_item term_code }
    let(:reports_today_folder) { mock_google_drive_item today }
    let(:supplemental_sources_folder) { mock_google_drive_item 'supplemental_sources' }

    it 'creates folders, uploads sheets, and writes log' do
      expect(fake_remote_drive).to receive(:find_folders).with(no_args).and_return []
      expect(fake_remote_drive).to receive(:check_conflicts_and_create_folder)
        .with(term_code, nil, anything).and_return term_folder

      %w(departments exports imports reports).each do |title|
        expect(fake_remote_drive).to receive(:check_conflicts_and_create_folder)
          .with(title, term_folder, anything).and_return mock_google_drive_item(title)
      end

      expect(fake_remote_drive).to receive(:check_conflicts_and_create_folder)
        .with('supplemental_sources', term_folder, anything).and_return supplemental_sources_folder

      %w(courses course_instructors course_supervisors instructors supervisors).each do |sheet|
        expect(fake_remote_drive).to receive(:check_conflicts_and_upload)
          .with(kind_of(Oec::Worksheet), sheet, Oec::Worksheet, supplemental_sources_folder, anything)
          .and_return mock_google_drive_item(sheet)
      end

      expect(fake_remote_drive).to receive(:check_conflicts_and_create_folder)
        .with(today, anything, anything).and_return reports_today_folder
      expect(fake_remote_drive).to receive(:check_conflicts_and_upload)
        .with(kind_of(Pathname), logfile, 'text/plain', reports_today_folder, anything)
        .and_return mock_google_drive_item(logfile)

      subject.run
    end
  end

  context 'Google Drive connection error' do
    before do
      expect(fake_remote_drive).to receive(:check_conflicts_and_create_folder).at_least(1).times
        .and_raise Errors::ProxyError, 'A confounding error'
      expect(fake_remote_drive).to receive(:find_nested).at_least(1).times
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
      expect(fake_remote_drive).to receive(:find_folders).with(no_args).and_return []
      expect(fake_remote_drive).not_to receive(:check_conflicts_and_upload)
      subject.run
    end
  end
end
