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
  it 'supports Torquebox background jobs' do
    expect(subject.background.class).to eq TorqueBox::Messaging::Backgroundable::BackgroundProxy
  end

  it 'saves current object state to cache' do
    job_id = subject.background_job_id
    subject.background_job_save
    expect(Canvas::BackgroundJob.find(subject.background_job_id)).to_not eq nil
  end

  it 'provides consistent job id' do
    allow(Canvas::BackgroundJob).to receive(:unique_job_id).and_return('generated.cache.key1','generated.cache.key2')
    expect(subject.background_job_id).to eq 'generated.cache.key1'
    expect(subject.background_job_id).to eq 'generated.cache.key1'
  end

end
