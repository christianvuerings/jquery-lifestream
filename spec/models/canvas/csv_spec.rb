require "spec_helper"

describe Canvas::Csv do

  let(:user_ids)  { ["1234","1235"] }

  describe "#accumulate_user_data" do
    context 'when all users known' do
      before do
        people_attributes = [
          { "ldap_uid"=>"1234", "first_name"=>"John", "last_name"=>"Smith", "email_address"=>"johnsmith@example.com", "student_id"=>nil, "affiliations"=>"EMPLOYEE-TYPE-ACADEMIC" },
          { "ldap_uid"=>"1235", "first_name"=>"Jane", "last_name"=>"Smith", "email_address"=>"janesmith@example.com", "student_id"=>nil, "affiliations"=>"EMPLOYEE-TYPE-ACADEMIC" },
        ]
        CampusOracle::Queries.should_receive(:get_basic_people_attributes).with(["1234","1235"]).and_return(people_attributes)
      end

      it "should assemble array with user attribute hashes" do
        result = subject.accumulate_user_data(user_ids, [])
        result.should be_an_instance_of Array
        expect(result.count).to eq 2
        expect(result[0]).to be_an_instance_of Hash
        expect(result[0]["user_id"]).to eq "UID:1234"
        expect(result[0]["login_id"]).to eq "1234"
        expect(result[0]["first_name"]).to eq "John"
        expect(result[0]["last_name"]).to eq "Smith"
        expect(result[0]["email"]).to eq "johnsmith@example.com"
        expect(result[0]["status"]).to eq "active"
      end

      it "should not remove the contents of the user_ids argument" do
        result = subject.accumulate_user_data(user_ids, [])
        result.should be_an_instance_of Array
        expect(user_ids).to be_an_instance_of Array
        expect(user_ids.count).to eq 2
      end
    end

    context 'when querying many user records from the DB' do
      it "should find all available ones" do
        known_first = ['238382', '2040']
        known_last = ['3060', '211159', '322279']
        lotsa = []
        lotsa.concat(known_first)
        (1..1000).each {|u| lotsa << u}
        lotsa.concat(known_last)
        user_data = []
        subject.accumulate_user_data(lotsa, user_data)
        known_users = user_data.select do |row|
          known_first.include?(row['login_id']) || known_last.include?(row['login_id'])
        end
        known_users.length.should == (known_first.length + known_last.length)
      end
    end
  end

  describe "#csv_count" do
    let(:csv_filepath) { 'tmp/csv_count_test.csv' }
    let(:csv_rows) do
      [
        ['45','John','Smith','johnsmith@example.com'],
        ['46','Jane','Smith','janesmith@example.com'],
        ['63','Robin','Williams','rwilliams@example.com'],
      ]
    end
    let(:csv_file) { subject.make_csv(csv_filepath, 'id,first_name,last_name,email_address', csv_rows) }
    after { delete_files_if_exists([csv_filepath]) }
    it "returns number of records in csv file" do
      result = subject.csv_count(csv_file)
      expect(result).to eq 3
    end
  end

end
