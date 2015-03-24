describe Oec::Students do

  context 'the exported file in the tmp directory' do

    let!(:spec_file) { CSV.read('fixtures/oec/students.csv') }
    let!(:ccn_set) { [12345, 67890].to_set }
    let!(:annotated_ccn_hash) { {12345 => %w(A B), 67890 => %w(CHEM MSB), 11891 => %w(GSI) } }

    before(:each) {
      all_students_query = []
      spec_file.each_with_index do |row, index|
        if index > 0
          all_students_query << {
            'ldap_uid' => row[0],
            'sis_id' => row[1],
            'first_name' => row[2],
            'last_name' => row[3],
            'email_address' => row[4]
          }
        end
      end
      complete_ccn_set = ccn_set.merge annotated_ccn_hash.keys
      Oec::Queries.stub(:get_all_students).with(complete_ccn_set).and_return(all_students_query)
    }

    let!(:export) { Oec::Students.new(ccn_set, annotated_ccn_hash, 'tmp/oec').export }

    subject { CSV.read(export[:filename]) }
    it {
      should_not be_nil
      should =~ spec_file
    }
  end

end
