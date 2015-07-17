describe Canvas::CourseUsers do

  let(:user_id)             { 754401 }
  let(:canvas_course_id)    { 1276293 }
  subject                   { Canvas::CourseUsers.new(:user_id => user_id, :course_id => canvas_course_id) }

  it 'provides course users' do
    users = subject.course_users[:body]
    expect(users.count).to eq 11
    expect(users[0]['id']).to eq 4862319
    expect(users[0]['name']).to eq 'Ted Andrew Greenwald'
    expect(users[0]['sis_user_id']).to eq 'UID:4000123'
    expect(users[0]['sis_login_id']).to eq '4000123'
    expect(users[0]['login_id']).to eq '4000123'
    expect(users[0]['enrollments'].count).to eq 1
    expect(users[0]['enrollments'][0]['course_id']).to eq 1276293
    expect(users[0]['enrollments'][0]['course_section_id']).to eq 1312012
    expect(users[0]['enrollments'][0]['id']).to eq 20187382
    expect(users[0]['enrollments'][0]['type']).to eq 'StudentEnrollment'
    expect(users[0]['enrollments'][0]['role']).to eq 'StudentEnrollment'
    expect(users[0]['enrollments'][0]['grades']).to be_an_instance_of Hash
    expect(users[0]['enrollments'][0]['grades']['current_score']).to eq 34.9
    expect(users[0]['enrollments'][0]['grades']['final_score']).to eq 34.9
    expect(users[0]['enrollments'][0]['grades']['current_grade']).to eq 'F'
    expect(users[0]['enrollments'][0]['grades']['final_grade']).to eq 'F'
  end

  it 'uses cache by default' do
    expect(Canvas::CourseUsers).to receive(:fetch_from_cache).and_return([])
    users = subject.course_users
    expect(users).to be_empty
  end

  it 'bypasses cache when cache option is false' do
    expect(Canvas::CourseUsers).to_not receive(:fetch_from_cache)
    users = subject.course_users(cache: false)
    expect(users[:body]).to have(11).items
  end

  it 'uses paging callback during request if present' do
    paging_callback = double
    expect(paging_callback).to receive(:background_job_set_total_steps).with('2').twice.and_return(true)
    expect(paging_callback).to receive(:background_job_complete_step).with('Retrieving Canvas Course Users - Page 1 of 2').and_return(true).ordered
    expect(paging_callback).to receive(:background_job_complete_step).with('Retrieving Canvas Course Users - Page 2 of 2').and_return(true).ordered
    worker = Canvas::CourseUsers.new(:user_id => user_id, :course_id => canvas_course_id, :paging_callback => paging_callback)
    worker.course_users(cache: false)
  end
end
