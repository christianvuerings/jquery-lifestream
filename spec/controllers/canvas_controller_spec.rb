require "spec_helper"
require "support/shared_examples"

describe CanvasController do

  before do
    session[:user_id] = "12345"
    session[:canvas_user_id] = "4321321"
    session[:canvas_course_id] = "767330"
    Canvas::CourseUser.stub(:is_course_admin?).and_return(true)
  end

  context "when serving index of external applications within canvas" do
    it_should_behave_like "an api endpoint" do
      before { Canvas::ExternalTools.stub(:new).and_raise(RuntimeError, "Something went wrong") }
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

end
