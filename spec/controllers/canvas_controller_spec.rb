require "spec_helper"
require "support/shared_examples"

describe CanvasController do

  let(:canvas_user_id) { '3323890' }
  let(:uid) { '1234' }

  context "when serving index of external applications within canvas" do
    it_should_behave_like "an api endpoint" do
      before { allow(Canvas::ExternalTools).to receive(:new).and_raise(RuntimeError, "Something went wrong") }
      let(:make_request) { get :external_tools }
    end

    it "returns public list of external tools" do
      get :external_tools
      expect(response.status).to eq(200)
      response_json = JSON.parse(response.body)
      expect(response_json).to be_an_instance_of Hash
      response_json.each do |name, id|
        expect(name).to be_an_instance_of String
        expect(id).to be_an_instance_of Fixnum
      end
    end

    it "should set cross origin access control headers" do
      get :external_tools
      expect(response.header["Access-Control-Allow-Origin"]).to eq "#{Settings.canvas_proxy.url_root}"
      expect(response.header["Access-Control-Allow-Methods"]).to eq 'GET, OPTIONS, HEAD'
      expect(response.header["Access-Control-Max-Age"]).to eq '86400'
    end
  end

  context "when identifying if a user can provision course sites" do
    before do
      user_profile = double
      expect(user_profile).to receive(:login_id).and_return(uid)
      allow(Canvas::UserProfile).to receive(:new).with(:canvas_user_id => '3323890').and_return(user_profile)
    end

    it_should_behave_like "an api endpoint" do
      before { allow(User::Auth).to receive(:get).and_raise(RuntimeError, "Something went wrong") }
      let(:make_request) { get :user_can_create_course_site, :canvas_user_id => canvas_user_id }
    end

    context "when canvas user profile does not exist" do
      before { allow_any_instance_of(Canvas::UserProfile).to receive(:login_id).and_return(nil) }
      it "returns false" do
        get :user_can_create_course_site, :canvas_user_id => canvas_user_id
        expect(response.status).to eq(200)
        response_json = JSON.parse(response.body)
        expect(response['canCreateCourseSite']).to be_false
      end
    end

    context "when user is not authorized to create course site" do
      before { allow_any_instance_of(User::AuthPolicy).to receive(:can_create_canvas_course_site?).and_return(false) }
      it "returns false" do
        get :user_can_create_course_site, :canvas_user_id => canvas_user_id
        expect(response.status).to eq(200)
        response_json = JSON.parse(response.body)
        expect(response_json['canCreateCourseSite']).to be_false
      end
    end

    context "when user is authorized to create course site" do
      before { allow_any_instance_of(User::AuthPolicy).to receive(:can_create_canvas_course_site?).and_return(true) }
      it "returns true" do
        get :user_can_create_course_site, :canvas_user_id => canvas_user_id
        expect(response.status).to eq(200)
        response_json = JSON.parse(response.body)
        expect(response_json['canCreateCourseSite']).to be_true
      end
    end

  end
end
