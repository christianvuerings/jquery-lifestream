require "spec_helper"

describe CanvasCsv do

	let(:canvas_csv) 	{ CanvasCsv.new }

	describe "#accumulate_user_data" do
		it "should assemble array with user attribute hashes" do
			people_attributes = [
				{
					"ldap_uid"=>"1234",
					"first_name"=>"John",
					"last_name"=>"Smith",
					"email_address"=>"jsmith@example.com",
					"student_id"=>nil,
					"affiliations"=>"EMPLOYEE-TYPE-ACADEMIC"
				}
			]
			CampusData.should_receive(:get_basic_people_attributes).with(["1234"]).and_return(people_attributes)
			result = canvas_csv.accumulate_user_data(['1234'], [])
			result.should be_an_instance_of Array
			result[0].should be_an_instance_of Hash
			result[0]["user_id"].should == "UID:1234"
			result[0]["login_id"].should == "1234"
			result[0]["first_name"].should == "John"
			result[0]["last_name"].should == "Smith"
			result[0]["email"].should == "jsmith@example.com"
			result[0]["status"].should == "active"
		end
	end
end
