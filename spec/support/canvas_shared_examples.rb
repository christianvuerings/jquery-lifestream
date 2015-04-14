###############################################################################################
# Canvas Shared Examples
# ----------------------
#
# Used to provide test functionality that is shared across tests.
# See https://www.relishapp.com/rspec/rspec-core/docs/example-groups/shared-examples
#
###############################################################################################

########################################################
# Canvas Controller Authorizations

shared_examples 'a canvas course admin authorized api endpoint' do

  let(:canvas_user_profile) do
    {
      'id'=>43232321,
      'name'=>'Michael Steven OWEN',
      'short_name'=>'Michael OWEN',
      'sortable_name'=>'OWEN, Michael',
      'sis_user_id'=>'UID:105431',
      'sis_login_id'=>'105431',
      'login_id'=>'105431',
      'avatar_url'=>'https://secure.gravatar.com/avatar/205e460b479e2e5b48aec07710c08d50',
      'title'=>nil,
      'bio'=>nil,
      'primary_email'=>'michael.s.owen@berkeley.edu',
      'time_zone'=>'America/Los_Angeles'
    }
  end

  let(:canvas_course_student_hash) do
    {
      'id' => 4321321,
      'name' => 'Michael Steven OWEN',
      'sis_user_id' => 'UID:105431',
      'sis_login_id' => '105431',
      'login_id' => '105431',
      'enrollments' => [
        {'course_id' => 767330, 'course_section_id' => 1312468, 'id' => 20241907, 'type' => 'StudentEnrollment', 'role' => 'StudentEnrollment'}
      ]
    }
  end

  let(:canvas_course_teacher_hash) do
    canvas_course_student_hash.merge({
      'enrollments' => [
        {'course_id' => 767330, 'course_section_id' => 1312468, 'id' => 20241908, 'type' => 'TeacherEnrollment', 'role' => 'TeacherEnrollment'}
      ]
    })
  end

  before do
    Canvas::UserProfile.any_instance.stub(:get).and_return(canvas_user_profile)
    Canvas::CourseUser.any_instance.stub(:request_course_user).and_return(canvas_course_student_hash)
    Canvas::Admins.any_instance.stub(:admin_user?).and_return(false)
  end

  context 'when user is a student' do
    it 'returns 403 error' do
      make_request
      expect(response.status).to eq(403)
      expect(response.body).to eq " "
    end
  end

  context 'when user is a course teacher' do
    before { Canvas::CourseUser.any_instance.stub(:request_course_user).and_return(canvas_course_teacher_hash) }
    it 'returns 200 success' do
      make_request
      expect(response.status).to eq(200)
    end
  end

  context 'when user is a canvas account admin' do
    before { Canvas::Admins.any_instance.stub(:admin_user?).and_return(true) }
    it 'returns 200 success' do
      make_request
      expect(response.status).to eq(200)
    end
  end

end

########################################################
# Classes using Canvas::BackgroundJob

shared_examples 'a background job worker' do
  let(:background_job_id) { 'Canvas::Egrades.1383330151057-67f4b934525501cb' }

  before do
    allow(Canvas::BackgroundJob).to receive(:unique_job_id).and_return(background_job_id)
    subject.background_job_initialize(:total_steps => 3)
  end

  it 'supports Torquebox background jobs' do
    expect(subject.background.class).to eq TorqueBox::Messaging::Backgroundable::BackgroundProxy
  end

  it 'provides consistent background job id' do
    allow(Canvas::BackgroundJob).to receive(:unique_job_id).and_return('generated.cache.key1','generated.cache.key2')
    subject.background_job_initialize(:total_steps => 3)
    expect(subject.background_job_id).to eq "#{subject.class.name}.generated.cache.key1"
    expect(subject.background_job_id).to eq "#{subject.class.name}.generated.cache.key1"
  end

  it 'reports custom specified job type' do
    subject.background_job_initialize(:job_type => 'officialSections')
    expect(subject.background_job_report[:jobType]).to eq 'officialSections'
  end

  it 'saves current object state to cache' do
    job_id = subject.background_job_id
    bg_job_object = Canvas::BackgroundJob.find(subject.background_job_id)
    expect(bg_job_object.background_job_id).to eq job_id
    expect(bg_job_object.background_job_report).to be_an_instance_of Hash
    expect(bg_job_object.background_job_report[:jobStatus]).to eq 'New'
  end

  context 'when background job state first saved to cache' do
    it 'returns initial background job report' do
      report = subject.background_job_report
      expect(report).to be_an_instance_of Hash
      expect(report[:jobId]).to be_an_instance_of String
      expect(report[:jobStatus]).to eq 'New'
      expect(report[:jobType]).to eq ''
      expect(report[:completedSteps]).to eq []
      expect(report[:percentComplete]).to eq 0.0
      expect(report[:errors]).to eq nil
    end

    it 'returns background job report with custom report values' do
      allow(Canvas::BackgroundJob).to receive(:unique_job_id).and_return(background_job_id)
      allow(subject).to receive(:background_job_report_custom).and_return({:customKey => 'customValue'})
      report = subject.background_job_report
      expect(report).to be_an_instance_of Hash
      expect(report[:customKey]).to eq 'customValue'
    end
  end

  context 'when background job in progress' do
    before do
      subject.background_job_complete_step('step 1')
      subject.background_job_complete_step('step 2')
    end
    it 'reports as processing based on total and completed steps' do
      cached_object = Canvas::BackgroundJob.find(subject.background_job_id)
      report = cached_object.background_job_report
      expect(report).to be_an_instance_of Hash
      expect(report[:jobId]).to be_an_instance_of String
      expect(report[:jobStatus]).to eq 'Processing'
      expect(report[:completedSteps]).to eq ['step 1', 'step 2']
      expect(report[:percentComplete]).to eq 0.67
      expect(report[:errors]).to eq nil
    end
  end

  context 'when background job completed' do
    before do
      subject.background_job_complete_step('step 1')
      subject.background_job_complete_step('step 2')
      subject.background_job_complete_step('step 3')
    end
    it 'reports as completed based on total and completed steps' do
      cached_object = Canvas::BackgroundJob.find(subject.background_job_id)
      report = cached_object.background_job_report
      expect(report).to be_an_instance_of Hash
      expect(report[:jobId]).to be_an_instance_of String
      expect(report[:jobStatus]).to eq 'Completed'
      expect(report[:completedSteps]).to eq ['step 1','step 2','step 3']
      expect(report[:percentComplete]).to eq 1
      expect(report[:errors]).to eq nil
    end
  end

  it 'reports errors when present' do
    subject.background_job_complete_step('step 1')
    subject.background_job_add_error('Something went wrong')
    cached_object = Canvas::BackgroundJob.find(subject.background_job_id)
    report = cached_object.background_job_report
    expect(report).to be_an_instance_of Hash
    expect(report[:jobId]).to be_an_instance_of String
    expect(report[:jobStatus]).to eq 'Error'
    expect(report[:completedSteps]).to eq ['step 1']
    expect(report[:percentComplete]).to eq 0.33
    expect(report[:errors]).to eq ['Something went wrong']

    subject.background_job_complete_step('step 2')
    subject.background_job_add_error('Something else went wrong')
    subject.background_job_complete_step('step 3')
    cached_object = Canvas::BackgroundJob.find(subject.background_job_id)
    report = cached_object.background_job_report
    expect(report).to be_an_instance_of Hash
    expect(report[:jobId]).to be_an_instance_of String
    expect(report[:jobStatus]).to eq 'Error'
    expect(report[:completedSteps]).to eq ['step 1','step 2','step 3']
    expect(report[:percentComplete]).to eq 1
    expect(report[:errors]).to eq ['Something went wrong', 'Something else went wrong']
  end

  it 'updates total steps' do
    subject.background_job_set_total_steps('4')
    subject.background_job_complete_step('step one')
    subject.background_job_complete_step('step two')
    cached_object = Canvas::BackgroundJob.find(subject.background_job_id)
    expect(cached_object.background_job_report[:percentComplete]).to eq 0.50
  end

  it 'reports as processing or completed based on total and completed steps' do
    cached_object = Canvas::BackgroundJob.find(subject.background_job_id)
    expect(cached_object.background_job_report[:jobStatus]).to eq 'New'
    subject.background_job_complete_step('step 1')
    cached_object = Canvas::BackgroundJob.find(subject.background_job_id)
    expect(cached_object.background_job_report[:jobStatus]).to eq 'Processing'
    subject.background_job_complete_step('step 2')
    cached_object = Canvas::BackgroundJob.find(subject.background_job_id)
    expect(cached_object.background_job_report[:jobStatus]).to eq 'Processing'
    subject.background_job_complete_step('step 3')
    cached_object = Canvas::BackgroundJob.find(subject.background_job_id)
    expect(cached_object.background_job_report[:jobStatus]).to eq 'Completed'
  end

end
