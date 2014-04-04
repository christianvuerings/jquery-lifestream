require 'spec_helper'

describe MyEventsController do
  let(:random_id) { rand(99999).to_s }

  shared_examples "failure response" do
    it { should_not be_success }
    it { subject.status.should eq(400) }
    it { subject.content_type.should eq("application/json") }
    it { JSON.parse(subject.body)[:status].should be_false }
  end

  context "#create" do
    context "failure scenarios" do
      context "JSON request, unauthenticated" do
        subject { post :create, { format: 'json'} }

        it { should_not be_success }
        it { subject.status.should eq(302) }
        it { subject.content_type.symbol.should eq(:html) }
        its(:location) { should be_include("auth/cas") }
      end

      # TODO fixing this test requires rspec 3, see CLC-3565 for details.
      #context "request type HTML, authenticated" do
      #  before(:each) { session[:user_id] = random_id }
      #
      #  subject { post :create, { format: 'html'} }
      #
      #  it { should_not be_success }
      #  it { subject.status.should eq(406) }
      #  it { subject.content_type.symbol.should eq(:html) }
      #end

      context "request type JSON, authenticated, no google access" do
        before(:each) { session[:user_id] = random_id }

        subject { post :create, { format: 'json'} }
        it_behaves_like "failure response"
      end

      context "request type JSON, authenticated, google access, bad payload" do
        before(:each) do
          session[:user_id] = random_id
          described_class.any_instance.stub(:check_google_access).and_return(true)
          described_class.any_instance.should_receive(:sanitize_input!).once
        end

        subject { post :create, { format: 'json', summary: "foo!" } }
        it_behaves_like "failure response"
      end

      context "request type JSON, authenticated, google access, bad dates in payload" do
        before(:each) do
          session[:user_id] = random_id
          described_class.any_instance.stub(:check_google_access).and_return(true)
        end

        subject do
          post :create, {
            format: 'json',
            summary: "foo!",
            start: { epoch: 'foo' },
            end: { epoch: 'baz' }
          }
        end

        it_behaves_like "failure response"
      end

    end

    context "success scenarios" do
      let!(:recorded_valid_input) do
        {
          summary: 'Fancy event',
          start: { epoch: 1380013560 },
          end: { epoch: 1380017160 }
        }
      end
      before(:each) do
        session[:user_id] = random_id
        described_class.any_instance.stub(:check_google_access).and_return(true)
        fake_proxy = GoogleApps::EventsInsert.new(fake: true, fake_options: { match_requests_on: [:method, :path, :body] })
        GoogleApps::EventsInsert.stub(:new).and_return(fake_proxy)
      end

      subject do
        post :create, {
          format: 'json',
        }.merge(recorded_valid_input)
      end

      it { should be_success }
      it { subject.status.should eq(200) }
      it { subject.content_type.should eq("application/json") }
      it { JSON.parse(subject.body)["status"].should be_true }
      it { JSON.parse(subject.body)["summary"].should eq("Fancy event") }
      it { JSON.parse(subject.body)["id"].should be_present }
    end
  end

end
