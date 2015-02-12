require 'spec_helper'

describe CanvasProjectProvisionController do
  let(:uid) { rand(99999).to_s }
  let(:project_name) { 'My Test Project' }
  let(:account_id) { Settings.canvas_proxy.projects_account_id }
  let(:term_id) { Settings.canvas_proxy.projects_term_id }
  let(:unique_sis_project_id) { '67f4b934525501cb' }
  let(:new_course_hash) do
    {
      "id"=>23,
      "account_id"=> account_id,
      "name"=> project_name,
      "course_code"=> project_name,
      "sis_course_id"=>"PROJ:#{unique_sis_project_id}",
      "workflow_state"=>"unpublished"
    }
  end
  before do
    session[:user_id] = uid
    allow_any_instance_of(AuthenticationStatePolicy).to receive(:can_create_canvas_project_site?).and_return(true)
  end

  describe '#create_project_site' do
    before { allow_any_instance_of(Canvas::ProjectProvision).to receive(:create_project).and_return(new_course_hash) }

    it_should_behave_like "an api endpoint" do
      before { allow_any_instance_of(Canvas::ProjectProvision).to receive(:create_project).and_raise(RuntimeError, "Something went wrong") }
      let(:make_request) { post :create_project_site, :name => project_name }
    end

    it_should_behave_like "a user authenticated api endpoint" do
      let(:make_request) { post :create_project_site, :name => project_name }
    end

    context "when user is not authorized" do
      before { allow_any_instance_of(AuthenticationStatePolicy).to receive(:can_create_canvas_project_site?).and_return(false) }
      it "should respond with empty http 403" do
        post :create_project_site, :name => project_name
        expect(response.status).to eq 403
        expect(response.body).to eq ' '
      end
    end

    it 'should respond with course details' do
      post :create_project_site, :name => project_name
      assert_response 200
      result = JSON.parse(response.body)
      expect(result).to be_an_instance_of Hash
      puts "result: #{result.inspect}"
    end
  end
end
