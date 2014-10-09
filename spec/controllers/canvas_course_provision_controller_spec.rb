require 'spec_helper'

describe CanvasCourseProvisionController do

  describe '#create_course_site' do
    before do
      @instructor_id = '1234'       # represents UID for instructor / teacher creating courses
      @ccns = ['12345', '12348']    # represents the course control numbers associated with each course section
      @term_slug = 'fall-2014'      # represents the term for the course being created
    end

    it 'responds with empty 401 response when SecurityError exception is raised' do
      subject.stub(:valid_model).and_raise(SecurityError)
      post :create_course_site, ccns: @ccns, admin_acting_as: @instructor_id, term_slug: @term_slug
      assert_response(401)
      response.body.should == ' '
    end

    it 'responds with error response when StandardError raised' do
      subject.stub(:valid_model).and_raise(ArgumentError, 'This is the error message')
      post :create_course_site, ccns: @ccns, admin_acting_as: @instructor_id, term_slug: @term_slug
      assert_response :success
      json_response = JSON.parse(response.body)

      json_response['job_request_status'].should == 'Error'
      json_response['job_id'].should be_nil
      json_response['error'].should == 'This is the error message'
    end

    it 'responds with success when course provisioning job is created successful' do
      course_provisioning_job_id = 'canvas.courseprovision.12345.1383330151057'
      canvas_course_provision_double = double
      canvas_course_provision_double.stub(:create_course_site).and_return(course_provisioning_job_id)
      subject.stub(:valid_model).and_return(canvas_course_provision_double)

      post :create_course_site, ccns: @ccns, admin_acting_as: @instructor_id, term_slug: @term_slug
      assert_response :success
      json_response = JSON.parse(response.body)
      json_response['job_request_status'].should == 'Success'
      json_response['job_id'].should == 'canvas.courseprovision.12345.1383330151057'
    end
  end

  describe '#job_status' do
    it 'returns error if canvas course provisioning job not found' do
      get :job_status, job_id: 'canvas.courseprovision.12345.1383330151057'
      assert_response :success
      json_response = JSON.parse(response.body)
      json_response['job_id'].should == 'canvas.courseprovision.12345.1383330151057'
      json_response['status'].should == 'Error'
      json_response['error'].should == 'Unable to find course provisioning job'
    end

    it 'returns status of canvas course provisioning job' do
      cpcs = Canvas::ProvideCourseSite.new('1234')
      cpcs.instance_eval { @status = 'Processing'; @completed_steps = ['Prepared courses list', 'Identified department sub-account'] }
      cpcs.save

      get :job_status, job_id: cpcs.job_id
      assert_response :success
      json_response = JSON.parse(response.body)
      json_response['job_id'].should == cpcs.job_id
      json_response['status'].should == 'Processing'
      json_response['completed_steps'][0].should == 'Prepared courses list'
      json_response['completed_steps'][1].should == 'Identified department sub-account'
    end
  end

  describe '#valid_model' do
    it 'raises SecurityError if session id not present' do
      session.stub(:[]).with(:user_id).and_return(nil)
      instructor_id = '1234'
      expect { subject.valid_model({}) }.to raise_error(SecurityError, 'Bad request made to Canvas Course Provision: No session user')
    end

    it 'returns Canvas::CourseProvision object initialized using actual user and act_as id' do
      user_id = '1044777'
      as_instructor_id = '1234'
      session.stub(:[]).with(:user_id).and_return(user_id)
      result = subject.valid_model({ admin_acting_as: as_instructor_id })
      result.should be_an_instance_of Canvas::CourseProvision
      result.instance_eval { @uid }.should == '1044777'
      result.instance_eval { @admin_acting_as }.should == '1234'
    end

    it 'does not allow a combination of act-as and by-CCNs' do
      superuser_id = rand(99999).to_s
      session[:user_id] = superuser_id
      #session.stub(:[]).with(:user_id).and_return(superuser_id)
      get :get_feed, admin_acting_as: rand(99999).to_s, admin_by_ccns: [rand(99999)], admin_term_slug: 'spring-2014'
      assert_response(400)
    end

  end

end
