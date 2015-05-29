require 'spec_helper'

describe Canvas::TurnitinReporter do
  let!(:fake_courses_report_proxy) { Canvas::CoursesReport.new(fake: true, account_id: Settings.canvas_proxy.turnitin_account_id) }
  let(:term_id) {'TERM:2015-B'}
  subject {Canvas::TurnitinReporter.new(term_id)}

  context 'with recorded test data' do
    before do
      allow(Settings.canvas_proxy).to receive(:fake).and_return(true)
    end
    describe '#generate_report' do
      it 'reports the expected summary' do
        report = subject.generate_report
        expect(report.length).to eq 3
        assignment_rows = report.to_a.slice(0, report.length - 1)
        assignment_rows.each do |row|
          expect(row).to include(
            'Course ID' => be_present,
            'Course Code' => be_present,
            'Assignment URL' => be_present,
            'Assignment Name' => be_present,
            'Creation Date' => be_present
          )
        end
        totals_row = report[report.length - 1]
        expect(totals_row).to include(
          'Total Enabled Courses' => 1,
          'Total Enabled Assignments' => 2
        )
      end
    end
    describe '#generate_csv' do
      it 'produces a good CSV file' do
        csv_filename = subject.generate_csv
        parsed_csv = CSV.read(csv_filename, {headers: true})
        expect(parsed_csv.length).to eq 3
      end
    end
  end

  describe '#generate_csv' do
    context 'when no enabled assignments were found' do
      before do
        allow(subject).to receive(:generate_report).and_return(
          [{
            'Total Enabled Courses' => 0,
            'Total Enabled Assignments' => 0
          }]
        )
      end
      it 'produces a good CSV file' do
        csv_filename = subject.generate_csv
        parsed_csv = CSV.read(csv_filename, {headers: true})
        expect(parsed_csv.length).to eq 1
      end
    end

  end

end
