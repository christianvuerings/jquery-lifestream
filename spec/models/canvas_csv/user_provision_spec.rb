describe CanvasCsv::UserProvision do

  describe '#csv_filename_prefix' do
    before do
      allow(SecureRandom).to receive(:hex).and_return 'f76d1b860dcc152c'
      allow(DateTime).to receive(:now).and_return DateTime.strptime('2013-11-05T12:05:05+07:00', '%Y-%m-%dT%H:%M:%S%z')
    end

    it 'returns filename prefix with current date and random hex' do
      expect(subject.csv_filename_prefix).to eq 'tmp/canvas/user_provision-2013-11-05-f76d1b860dcc152c'
    end

    it 'caches and returns previously generated filename prefix' do
      subject.csv_filename_prefix
      allow(SecureRandom).to receive(:hex).and_return 'd65c0a759cbb041b'
      expect(subject.csv_filename_prefix).to eq 'tmp/canvas/user_provision-2013-11-05-f76d1b860dcc152c'
    end
  end

  describe '#import_users' do
    before do
      allow(subject).to receive(:csv_filename_prefix).and_return 'tmp/canvas/user_provision-2013-11-05-f76d1b860dcc152c'
      user_definitions = [
        {'user_id'=>'UID:1234', 'login_id'=>'1234', 'first_name'=>'John', 'last_name'=>'Smith', 'email'=>'johnsmith@berkeley.edu', 'status'=>'active'},
        {'user_id'=>'UID:1235', 'login_id'=>'1235', 'first_name'=>'Jane', 'last_name'=>'Smith', 'email'=>'janesmith@berkeley.edu', 'status'=>'active'},
      ]
      allow(subject).to receive(:accumulate_user_data).with(['1234','1235']).and_return user_definitions
    end

    it 'raises exception if argument is not an array' do
      expect { subject.import_users('not an array') }.to raise_error(ArgumentError, 'User ID list is not an array')
    end

    it 'raises exception if argument contains element that is not a String' do
      expect { subject.import_users(['12344', 12345]) }.to raise_error(ArgumentError, 'User ID list contains value that is not of type String - \'12345\'')
    end

    it 'raises exception if argument contains element that is not numeric' do
      expect { subject.import_users(['12344', '123abc', '12346']) }.to raise_error(ArgumentError, 'User ID list contains value that is not numeric - \'123abc\'')
    end

    it 'passes transformed UID list to Canvas::SisImport#import_users as CSV definitions' do
      Canvas::SisImport.any_instance.should_receive(:import_users).with('tmp/canvas/user_provision-2013-11-05-f76d1b860dcc152c-users.csv').and_return true
      result = subject.import_users(['1234','1235'])
      expect(result).to eq true
    end

    it 'raises exception if user import failed' do
      Canvas::SisImport.any_instance.should_receive(:import_users).with('tmp/canvas/user_provision-2013-11-05-f76d1b860dcc152c-users.csv').and_return nil
      expect { subject.import_users(['1234', '1235']) }.to raise_error(RuntimeError, 'User import failed')
    end
  end
end
