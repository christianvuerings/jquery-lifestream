describe Canvas::UserCourses do

  context 'working against test data' do
    subject {Canvas::UserCourses.new(fake: true).courses}
    its(:size) {should eq 2}

    it 'should not include access-restricted entries' do
      expect(subject.select { |course| course['name'] == 'Temps Perdu' }).to be_empty
    end

    it 'should not include inexplicably malformed entries' do
      expect(subject.select { |course| course['id'] == '0xDEAD' }).to be_empty
    end
  end

  it 'should get courses as known student' do
    courses = Canvas::UserCourses.new(:user_id => @user_id).courses
    expect(courses).to_not be_empty
    expect(courses[0]['course_code']).to be_present
    expect(courses[0]['term']['name']).to be_present
  end

  context 'request failure' do
    subject { Canvas::UserCourses.new }
    let(:failing_request) { {method: :get} }
    let(:response) { subject.courses_response }
    it_should_behave_like 'a paged Canvas proxy handling request failure'
  end

end
