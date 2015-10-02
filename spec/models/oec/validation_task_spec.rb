describe Oec::ValidationTask do
  let(:term_code) { '2015-B' }
  let(:task) { Oec::ValidationTask.new(term_code: term_code, local_write: 'Y') }

  include_context 'OEC enrollment data merge'

  context 'valid fixture data' do
    it 'should pass validation' do
      allow(Rails.logger).to receive(:info)
      expect(Rails.logger).to receive(:info).with /Validation passed./
      task.run
    end
  end

  shared_examples 'validation error logging' do
    it 'should log error' do
      merged_course_confirmations_csv.concat invalid_row
      allow(Rails.logger).to receive(:error)
      expect(Rails.logger).to receive(:error).with /Validation failed!/
      task.run
      expect(task.errors[sheet_name][key].keys.first).to eq expected_message
    end
  end

  context 'conflicting instructor data' do
    let(:invalid_row) { '2015-B-32960,2015-B-32960,GWS 103 LEC 001 IDENTITY ACROSS DIF,,,GWS,103,LEC,001,P,104033,UID:104033,BAD_FIRST_NAME,Ffff,ffff@berkeley.edu,Y,GWS,F,,01-26-2015,05-11-2015' }
    let(:sheet_name) { 'instructors' }
    let(:key) { '104033' }
    let(:expected_message) { "Conflicting values found under FIRST_NAME: 'Flora', 'BAD_FIRST_NAME'" }
    include_examples 'validation error logging'
  end

  context 'conflicting course dates' do
    let(:invalid_row) { '2015-B-34818,2015-B-34818,LGBT 100 LEC 001 SPECIAL TOPICS,,,LGBT,100,LEC,001,P,77865,UID:77865,Doris,Dddd,dddd@berkeley.edu,Y,LGBT,F,Y,02-01-2015,05-01-2015' }
    let(:sheet_name) { 'courses' }
    let(:key) { '2015-B-34818' }
    let(:expected_message) { "Conflicting values found under END_DATE: '04-01-2015', '05-01-2015'" }
    include_examples 'validation error logging'
  end

  context 'courses sheet validations' do
    let(:sheet_name) { 'courses' }
    let(:key) { '2015-B-99999' }

    context 'blank field' do
      let(:invalid_row) { '2015-B-99999,2015-B-99999,BIOLOGY 150 LEC 001 VINDICATION OF RIGHTS,,,BIOLOGY,150,LEC,001,P,155555,UID:155555,Zachary,Zzzz,zzzz@berkeley.edu,Y,,F,,01-26-2015,05-11-2015' }
      let(:expected_message) { 'Blank DEPT_FORM' }
      include_examples 'validation error logging'
    end

    context 'invalid BIOLOGY department form' do
      let(:invalid_row) { '2015-B-99999,2015-B-99999,BIOLOGY 150 LEC 001 VINDICATION OF RIGHTS,,,BIOLOGY,150,LEC,001,P,155555,UID:155555,Zachary,Zzzz,zzzz@berkeley.edu,Y,SPANISH,F,,01-26-2015,05-11-2015' }
      let(:expected_message) { 'Unexpected for BIOLOGY course: DEPT_FORM SPANISH' }
      include_examples 'validation error logging'
    end

    context 'invalid course id' do
      let(:invalid_row) { '2015-B-999991,2015-B-999991,GWS 150 LEC 001 VINDICATION OF RIGHTS,,,GWS,150,LEC,001,P,155555,UID:155555,Zachary,Zzzz,zzzz@berkeley.edu,Y,GWS,F,,01-26-2015,05-11-2015' }
      let(:key) { '2015-B-999991' }
      let(:expected_message) { 'Invalid COURSE_ID 2015-B-999991' }
      include_examples 'validation error logging'
    end

    context 'non-matching COURSE_ID_2' do
      let(:invalid_row) { '2015-B-99999,2015-B-99998,GWS 150 LEC 001 VINDICATION OF RIGHTS,,,GWS,150,LEC,001,P,155555,UID:155555,Zachary,Zzzz,zzzz@berkeley.edu,Y,GWS,F,,01-26-2015,05-11-2015' }
      let(:expected_message) { 'Non-matching COURSE_ID_2 2015-B-99998' }
      include_examples 'validation error logging'
    end

    context 'unexpected GSI evaluation type' do
      let(:key) { '2015-B-99999_GSI' }
      let(:invalid_row) { '2015-B-99999_GSI,2015-B-99999_GSI,GWS 150 LEC 001 VINDICATION OF RIGHTS,,,GWS,150,LEC,001,P,155555,UID:155555,Zachary,Zzzz,zzzz@berkeley.edu,Y,GWS,F,,01-26-2015,05-11-2015' }
      let(:expected_message) { 'Unexpected EVALUATION_TYPE F' }
      include_examples 'validation error logging'
    end

    context 'course ID in wrong term' do
      let(:invalid_row) { '2014-B-99999,2014-B-99999,GWS 150 LEC 001 VINDICATION OF RIGHTS,,,GWS,150,LEC,001,P,155555,UID:155555,Zachary,Zzzz,zzzz@berkeley.edu,Y,GWS,F,,01-26-2015,05-11-2015' }
      let(:key) { '2014-B-99999' }
      let(:expected_message) { 'Incorrect term code in COURSE_ID 2014-B-99999' }
      include_examples 'validation error logging'
    end

    context 'end date before start date' do
      let(:invalid_row) { '2015-B-99999,2015-B-99999,GWS 150 LEC 001 VINDICATION OF RIGHTS,,,GWS,150,LEC,001,P,155555,UID:155555,Zachary,Zzzz,zzzz@berkeley.edu,Y,GWS,F,Y,03-26-2015,03-11-2015' }
      let(:key) { '2015-B-99999' }
      let(:expected_message) { 'Mismatched START_DATE 03-26-2015, END_DATE 03-11-2015' }
      include_examples 'validation error logging'
    end

    context 'start and end date in different years' do
      let(:invalid_row) { '2015-B-99999,2015-B-99999,GWS 150 LEC 001 VINDICATION OF RIGHTS,,,GWS,150,LEC,001,P,155555,UID:155555,Zachary,Zzzz,zzzz@berkeley.edu,Y,GWS,F,Y,01-26-2015,05-11-2016' }
      let(:key) { '2015-B-99999' }
      let(:expected_message) { 'Mismatched START_DATE 01-26-2015, END_DATE 05-11-2016' }
      include_examples 'validation error logging'
    end

    context 'default dates for modular course' do
      let(:invalid_row) { '2015-B-99999,2015-B-99999,GWS 150 LEC 001 VINDICATION OF RIGHTS,,,GWS,150,LEC,001,P,155555,UID:155555,Zachary,Zzzz,zzzz@berkeley.edu,Y,GWS,F,Y,01-26-2015,05-11-2015' }
      let(:key) { '2015-B-99999' }
      let(:expected_message) { 'Default term dates 01-26-2015 to 05-11-2015 for modular course' }
      include_examples 'validation error logging'
    end

    context 'non-default dates for non-modular course' do
      let(:invalid_row) { '2015-B-99999,2015-B-99999,GWS 150 LEC 001 VINDICATION OF RIGHTS,,,GWS,150,LEC,001,P,155555,UID:155555,Zachary,Zzzz,zzzz@berkeley.edu,Y,GWS,F,,02-26-2015,05-11-2015' }
      let(:key) { '2015-B-99999' }
      let(:expected_message) { 'Unexpected dates 02-26-2015 to 05-11-2015 for non-modular course' }
      include_examples 'validation error logging'
    end

    context 'unexpected evaluation type' do
      let(:invalid_row) { '2015-B-99999,2015-B-99999,GWS 150 LEC 001 VINDICATION OF RIGHTS,,,GWS,150,LEC,001,P,155555,UID:155555,Zachary,Zzzz,zzzz@berkeley.edu,Y,GWS,GAUNTLET,,01-26-2015,05-11-2015' }
      let(:key) { '2015-B-99999' }
      let(:expected_message) { 'Unexpected EVALUATION_TYPE GAUNTLET' }
      include_examples 'validation error logging'
    end

    context 'unexpected MODULAR_COURSE value' do
      let(:invalid_row) { '2015-B-99999,2015-B-99999,GWS 150 LEC 001 VINDICATION OF RIGHTS,,,GWS,150,LEC,001,P,155555,UID:155555,Zachary,Zzzz,zzzz@berkeley.edu,Y,GWS,F,F12,01-26-2015,05-11-2015' }
      let(:key) { '2015-B-99999' }
      let(:expected_message) { 'Unexpected MODULAR_COURSE value F12' }
      include_examples 'validation error logging'
    end
  end

  context 'instructors sheet validations' do
    let(:sheet_name) { 'instructors' }

    context 'non-numeric UID' do
      let(:key) { '155555Z' }
      let(:invalid_row) { '2015-B-99999,2015-B-99999,GWS 150 LEC 001 VINDICATION OF RIGHTS,,,GWS,150,LEC,001,P,155555Z,UID:155555Z,Zachary,Zzzz,zzzz@berkeley.edu,Y,GWS,F,,01-26-2015,05-11-2015' }
      let(:expected_message) { 'Non-numeric LDAP_UID 155555Z' }
      include_examples 'validation error logging'
    end
  end

  context 'repeated errors' do
    before do
      merged_course_confirmations_csv.concat "2015-B-99999,2015-B-99999,GWS 150 LEC 001 VINDICATION OF RIGHTS,,,GWS,150,LEC,001,P,155555Z,UID:155555Z,Zachary,Zzzz,zzzz@berkeley.edu,Y,GWS,F,,01-26-2015,05-11-2015\n"
      merged_course_confirmations_csv.concat "2015-B-99999,2015-B-99999,GWS 150 DIS 001 VINDICATION OF RIGHTS,,,GWS,150,LEC,001,P,155555Z,UID:155555Z,Zachary,Zzzz,zzzz@berkeley.edu,Y,GWS,F,,01-26-2015,05-11-2015\n"
      expect(task).not_to receive :export_sheet
    end

    it 'should record a row count' do
      task.run
      expect(task.errors['instructors']['155555Z'].first).to eq ['Non-numeric LDAP_UID 155555Z', 2]
    end
  end

end
