describe Oec::RemoteDrive do

  let(:term_code) { '2015-D' }
  let(:mock_dept_code) { 'MOCK_DEPT_CODE' }

  subject { described_class.new }

  context '#real', testext: true do
    context 'spreadsheet managed by department', :order => :defined do
      it 'should return nil when term not found' do
        spreadsheet = subject.find_dept_courses_spreadsheet('2008-B', mock_dept_code)
        expect(spreadsheet).to be_nil
      end

      it 'should return nil when dept not found' do
        spreadsheet = subject.find_dept_courses_spreadsheet(term_code, mock_dept_code)
        expect(spreadsheet).to be_nil
      end
    end
  end

end
