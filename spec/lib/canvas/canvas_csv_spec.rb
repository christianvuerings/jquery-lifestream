require "spec_helper"

describe CanvasCsv do

  let(:canvas_csv)  { CanvasCsv.new }
  let(:user_ids)  { ["1234","1235"] }

	describe "#accumulate_user_data" do
    before do
      people_attributes = [
        { "ldap_uid"=>"1234", "first_name"=>"John", "last_name"=>"Smith", "email_address"=>"johnsmith@example.com", "student_id"=>nil, "affiliations"=>"EMPLOYEE-TYPE-ACADEMIC" },
        { "ldap_uid"=>"1235", "first_name"=>"Jane", "last_name"=>"Smith", "email_address"=>"janesmith@example.com", "student_id"=>nil, "affiliations"=>"EMPLOYEE-TYPE-ACADEMIC" },
      ]
      CampusData.should_receive(:get_basic_people_attributes).with(["1234","1235"]).and_return(people_attributes)
    end

		it "should assemble array with user attribute hashes" do
			result = canvas_csv.accumulate_user_data(user_ids, [])
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
      result = canvas_csv.accumulate_user_data(user_ids, [])
      result.should be_an_instance_of Array
      expect(user_ids).to be_an_instance_of Array
      expect(user_ids.count).to eq 2
    end
	end
end
