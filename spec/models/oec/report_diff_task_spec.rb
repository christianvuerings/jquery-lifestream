describe Oec::ReportDiffTask do

  context '#fake' do
    let(:term_code) { '2015-D' }
    subject { described_class.new(term_code: term_code) }

    let(:fake_remote_drive) { double }
    let(:today) { '2015-08-31' }
    let(:now) { '092222' }
    let(:logfile) { "#{now}_report_diff_task.log" }

    before(:each) { allow(Oec::RemoteDrive).to receive(:new).and_return fake_remote_drive }
    let(:dept_code) { 'PSTAT' }
    let(:dept_name) { 'STAT' }
    let(:fake_code_mapping) { [Oec::CourseCode.new(dept_name: dept_name, catalog_id: nil, dept_code: dept_name, include_in_oec: true)] }

    before {
      allow(Oec::CourseCode).to receive(:by_dept_code).and_return({dept_code => fake_code_mapping})
      expect(subject).to receive(:write_log)
      expect(fake_remote_drive).to_not receive(:check_conflicts_and_upload)
    }

    it 'should produce no diff when department spreadsheet not found' do
      expect(fake_remote_drive).to receive(:find_dept_courses_spreadsheet).with(term_code, dept_code).and_return nil
      subject.run
    end
  end

end
