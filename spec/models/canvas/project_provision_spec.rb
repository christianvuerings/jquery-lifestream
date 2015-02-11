require 'spec_helper'

describe Canvas::ProjectProvision do
  let(:user_id) { rand(99999).to_s }
  let(:valid_course) do
    {
      "id"=>23,
      "account_id"=>1,
      "name"=>"Example Project Site",
      "course_code"=>"Example Course Code",
      "sis_course_id"=>"PROJ:67f4b934525501cb",
      "workflow_state"=>"unpublished"
    }
  end
  subject { Canvas::ProjectProvision.new(user_id) }

  describe '#unique_sis_project_id' do
    it 'returns unique sis_course_id for new project sites' do
      allow(SecureRandom).to receive(:hex).and_return('67f4b934525501cb', '15fb56bedaa3b437')
      course_1 = double()
      course_2 = double()
      expect(course_1).to receive(:course).and_return(valid_course)
      expect(course_2).to receive(:course).and_return(nil)
      expect(Canvas::SisCourse).to receive(:new).and_return(course_1, course_2)
      sis_course_id = subject.unique_sis_project_id
      expect(sis_course_id).to eq 'PROJ:15fb56bedaa3b437'
    end

    it 'raises exception if unique sis_course_id not found after 15 attempts' do
      allow_any_instance_of(Canvas::SisCourse).to receive(:course).and_return(valid_course)
      expect { subject.unique_sis_project_id }.to raise_error(RuntimeError, 'Unable to find unique SIS Course ID for Project Site')
    end
  end

  describe '#create_project' do
    let(:account_id) { Settings.canvas_proxy.projects_account_id }
    let(:term_id) { Settings.canvas_proxy.projects_term_id }
    let(:url_root) { Settings.canvas_proxy.url_root }
    let(:custom_role_id) { Settings.canvas_proxy.projects_owner_role_id }
    let(:project_name) { 'Test Project' }
    let(:unique_sis_project_id) { '67f4b934525501cb' }
    let(:new_course) do
      {
        "id"=>23,
        "account_id"=> account_id,
        "name"=> project_name,
        "course_code"=> project_name,
        "sis_course_id"=>"PROJ:#{unique_sis_project_id}",
        "workflow_state"=>"unpublished"
      }
    end
    let(:success_response) { double(status: 200, body: new_course.to_json) }
    let(:failure_response) { double(status: 500, body: nil) }

    before do
      allow(subject).to receive(:unique_sis_project_id).and_return(unique_sis_project_id)
      allow_any_instance_of(Canvas::Course).to receive(:create).and_return(success_response)
      allow(Canvas::CourseAddUser).to receive(:add_user_to_course).and_return(true)
    end

    it 'raises exception if error encountered with API request' do
      expect_any_instance_of(Canvas::Course).to receive(:create).with(account_id, project_name, project_name, term_id, unique_sis_project_id).and_return(failure_response)
      expect { subject.create_project(project_name) }.to raise_error Errors::ProxyError
    end

    it 'returns project site url' do
      expect_any_instance_of(Canvas::Course).to receive(:create).with(account_id, project_name, project_name, term_id, unique_sis_project_id).and_return(success_response)
      result = subject.create_project(project_name)
      expect(result).to be_an_instance_of Hash
      expect(result[:projectSiteId]).to eq 23
      expect(result[:projectSiteUrl]).to eq url_root + '/courses/' + result[:projectSiteId].to_s
    end

    it 'enrolls user in course site' do
      expect(Canvas::CourseAddUser).to receive(:add_user_to_course).with(user_id, 'TeacherEnrollment', new_course['id'], {:role_id => custom_role_id}).and_return(true)
      result = subject.create_project(project_name)
    end
  end
end
