require "spec_helper"

describe CanvasSiteCreationController do
  let(:uid) { rand(999999).to_s }
  let(:authorizations_hash) do
    {
      :can_create_course_site => false,
      :can_create_project_site => true,
    }
  end

  describe '#authorizations' do
    before do
      session['user_id'] = uid
      allow_any_instance_of(Canvas::SiteCreation).to receive(:authorizations).and_return(authorizations_hash)
    end

    it_should_behave_like "an api endpoint" do
      before { allow_any_instance_of(Canvas::SiteCreation).to receive(:authorizations).and_raise(RuntimeError, "Something went wrong") }
      let(:make_request) { get :authorizations }
    end

    it_should_behave_like "a user authenticated api endpoint" do
      let(:make_request) { get :authorizations }
    end

    it 'should return sections feed' do
      get :authorizations
      expect(response.status).to eq 200
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an_instance_of Hash
      expect(json_response['can_create_course_site']).to eq false
      expect(json_response['can_create_project_site']).to eq true
    end
  end

end
