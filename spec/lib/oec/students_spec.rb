require "spec_helper"

describe "Students" do

  let!(:random_time) { Time.now.to_f.to_s.gsub(".", "") }

  context "the exported file in the tmp directory" do
    let!(:spec_file) { CSV.read("fixtures/oec/students.csv") }
    let!(:ccns) { [12345, 67890] }

    before(:each) {
      all_students_query = []
      spec_file.each_with_index do |row, index|
        if index > 0
          all_students_query << {
            "ldap_uid" => row[0],
            "first_name" => row[1],
            "last_name" => row[2],
            "email_address" => row[3]
          }
        end
      end
      OecData.stub(:get_all_students).with(ccns).and_return(all_students_query)
    }

    let!(:export) { Students.new(ccns, []).export(random_time) }

    subject { CSV.read(export[:filename]) }
    it {
      should_not be_nil
      should eq(spec_file)
    }
  end

end
