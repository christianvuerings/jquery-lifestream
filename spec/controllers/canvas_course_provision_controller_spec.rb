require "spec_helper"

describe CanvasCourseProvisionController do

	describe "#create_course_site" do
		before do
			@instructor_id = "1234" 			# represents UID for instructor / teacher creating courses
			@ccns = ["12345", "12348"]		# represents the course control numbers associated with each course section
			@term_slug = "fall-2014"			# represents the term for the course being created
		end

		it "responds with empty 401 response when SecurityError exception is raised" do
			subject.stub(:valid_model).and_raise(SecurityError)
			post :create_course_site, ccns: @ccns, instructor_id: @instructor_id, term_slug: @term_slug
			assert_response(401)
			response.body.should == " "
		end

		it "responds with error response when StandardError raised" do
			subject.stub(:valid_model).and_raise(ArgumentError, 'This is the error message')
			post :create_course_site, ccns: @ccns, instructor_id: @instructor_id, term_slug: @term_slug
			assert_response :success
			json_response = JSON.parse(response.body)
			json_response["created_status"].should == "ERROR"
			json_response["created_message"].should == "This is the error message"
		end

		it "responds with success response when course site creation is successful" do
			success_response = {
				"created_status" => "Success",
				"created_course_site_url" => "https://berkeley.instructure.com/courses/1122334",
				"created_course_site_short_name" => "COMPSCI 47A SLF 001"
			}
			canvas_course_provision_double = double
			canvas_course_provision_double.stub(:create_course_site).and_return(success_response)
			subject.stub(:valid_model).and_return(canvas_course_provision_double)

			post :create_course_site, ccns: @ccns, instructor_id: @instructor_id, term_slug: @term_slug
			assert_response :success
			json_response = JSON.parse(response.body)
			json_response["created_status"].should == "Success"
			json_response["created_course_site_url"].should == "https://berkeley.instructure.com/courses/1122334"
			json_response["created_course_site_short_name"].should == "COMPSCI 47A SLF 001"
		end
	end

	describe "#valid_model" do
		it "raises SecurityError if session id not present" do
			session.stub!(:[]).with(:user_id).and_return(nil)
			instructor_id = "1234"
			expect { subject.valid_model(instructor_id) }.to raise_error(SecurityError, "Bad request made to Canvas Course Provision: No session user")
		end

		it "returns CanvasCourseProvision object initialized using actual user and act_as id" do
			user_id = "1044777"
			as_instructor_id = "1234"
			session.stub!(:[]).with(:user_id).and_return(user_id)
			result = subject.valid_model(as_instructor_id)
			result.should be_an_instance_of CanvasCourseProvision
			result.instance_eval { @uid }.should == "1044777"
			result.instance_eval { @as_instructor }.should == "1234"
		end
	end

end