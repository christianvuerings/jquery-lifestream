require "spec_helper"
require "support/shared_examples"

describe CanvasController do

  let(:canvas_user_id) { '3323890' }
  let(:uid) { '1234' }

  context "when serving index of external applications within canvas" do
    before do
      public_external_tools = {
        :global_tools => ['Global App 1' => 66, 'Global App 2' => 67],
        :official_course_tools => ['Official App 1' => 92, 'Official App 2' => 93]
      }
      allow(Canvas::ExternalTools).to receive(:public_list_as_json).and_return(public_external_tools)
    end

    it_should_behave_like "an api endpoint" do
      before { allow(Canvas::ExternalTools).to receive(:public_list_as_json).and_raise(RuntimeError, "Something went wrong") }
      let(:make_request) { get :external_tools }
    end

    it "returns public list of external tools" do
      get :external_tools
      expect(response.status).to eq(200)
      response_json = JSON.parse(response.body)
      expect(response_json).to be_an_instance_of Hash
      expect(response_json.keys).to eq ['global_tools', 'official_course_tools']
    end

    it "should set cross origin access control headers" do
      get :external_tools
      expect(response.header["Access-Control-Allow-Origin"]).to eq "#{Settings.canvas_proxy.url_root}"
      expect(response.header["Access-Control-Allow-Methods"]).to eq 'GET, OPTIONS, HEAD'
      expect(response.header["Access-Control-Max-Age"]).to eq '86400'
    end
  end

  context "when identifying if a user can provision course or project sites" do
    it_should_behave_like "an api endpoint" do
      before { allow_any_instance_of(Canvas::PublicAuthorizer).to receive(:can_create_site?).and_raise(RuntimeError, "Something went wrong") }
      let(:make_request) { get :user_can_create_site, :canvas_user_id => canvas_user_id }
    end

    context "when user is not authorized to create course site" do
      before { allow_any_instance_of(Canvas::PublicAuthorizer).to receive(:can_create_site?).and_return(false) }
      it 'includes Access-Control-Allow-Origin header' do
        get :user_can_create_site, :canvas_user_id => canvas_user_id
        expect(response.status).to eq(200)
        expect(response.headers).to be_an_instance_of Hash
        expect(response.headers['Access-Control-Allow-Origin']).to eq 'http://localhost:12345'
      end

      it 'returns false' do
        get :user_can_create_site, :canvas_user_id => canvas_user_id
        expect(response.status).to eq(200)
        response_json = JSON.parse(response.body)
        expect(response_json['canCreateSite']).to eq false
      end
    end

    context "when user is authorized to create course site" do
      before { allow_any_instance_of(Canvas::PublicAuthorizer).to receive(:can_create_site?).and_return(true) }

      it 'includes Access-Control-Allow-Origin header' do
        get :user_can_create_site, :canvas_user_id => canvas_user_id
        expect(response.status).to eq(200)
        expect(response.headers).to be_an_instance_of Hash
        expect(response.headers['Access-Control-Allow-Origin']).to eq 'http://localhost:12345'
      end

      it "returns true" do
        get :user_can_create_site, :canvas_user_id => canvas_user_id
        expect(response.status).to eq(200)
        response_json = JSON.parse(response.body)
        expect(response_json['canCreateSite']).to eq true
      end
    end

  end
end
