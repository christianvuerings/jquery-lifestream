describe Oec::Students do

  context 'the exported file in the tmp directory' do

    let!(:spec_file) { CSV.read('fixtures/oec/students.csv') }
    let!(:ccns) { [12345, 67890] }
    let!(:gsi_ccns) { [10731] }

    before(:each) {
      all_students_query = []
      spec_file.each_with_index do |row, index|
        if index > 0
          all_students_query << {
            'ldap_uid' => row[0],
            'first_name' => row[1],
            'last_name' => row[2],
            'email_address' => row[3]
          }
        end
      end
      Oec::Queries.stub(:get_all_students).with(ccns.concat gsi_ccns).and_return(all_students_query)
    }

    let!(:export) { Oec::Students.new(ccns, gsi_ccns, 'tmp/oec').export }

    subject { CSV.read(export[:filename]) }
    it {
      should_not be_nil
      should eq(spec_file)
    }
  end

end
