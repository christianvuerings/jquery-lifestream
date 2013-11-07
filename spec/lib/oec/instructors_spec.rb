require "spec_helper"

describe "Instructors" do

  let!(:random_time) { Time.now.to_f.to_s.gsub(".", "") }

  context "the exported file in the tmp directory" do
    let!(:spec_file) { CSV.read("fixtures/oec/instructors.csv") }
    let!(:ccns) { [12345, 67890] }

    before(:each) {
      all_instructors_query = []
      spec_file.each_with_index do |row, index|
        if index > 0
          all_instructors_query << {
            "ldap_uid" => row[0],
            "first_name" => row[1],
            "last_name" => row[2],
            "email_address" => row[3],
            "blue_role" => "23"
          }
        end
      end
      OecData.stub(:get_all_instructors).with(ccns).and_return(all_instructors_query)
    }

    let!(:export) { Instructors.new(ccns).export(random_time) }

    subject { CSV.read(export[:filename]) }
    it {
      should_not be_nil
      should eq(spec_file)
    }
  end
end
