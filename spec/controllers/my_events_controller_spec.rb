require 'spec_helper'

describe MyEventsController do
  let!(:valid_input) { {
    format: 'json',
    summary: 'Fancy event',
    start: { epoch: 1380013560 },
    end: { epoch: 1380017160 }
  } }
  before do
    allow(Settings.features).to receive(:reauthentication).and_return(false)
  end

  shared_examples "failure response" do
    it { should_not be_success }
    it { subject.status.should eq(400) }
    it { subject.content_type.should eq("application/json") }
    it { JSON.parse(subject.body)[:status].should be_false }
  end

  context "#create" do
    context "JSON request, unauthenticated" do
      subject { post :create, valid_input }
      it { should_not be_success }
      it { subject.status.should eq(302) }
      it { subject.content_type.symbol.should eq(:html) }
      its(:location) { should be_include("auth/cas") }
    end

    context 'authenticated' do
      let(:random_id) { rand(99999).to_s }
      before do
        session[:user_id] = random_id
      end

      context "failure scenarios" do

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
          subject { post :create, { format: 'json'} }
          it_behaves_like "failure response"
        end

        context "request type JSON, authenticated, google access, bad payload" do
          before(:each) do
            described_class.any_instance.stub(:check_google_access).and_return(true)
            described_class.any_instance.should_receive(:sanitize_input!).once
          end

          subject { post :create, { format: 'json', summary: "foo!" } }
          it_behaves_like "failure response"
        end

        context "request type JSON, authenticated, google access, bad dates in payload" do
          before(:each) do
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

        context 'viewing as another user' do
          before do
            session[:original_user_id] = rand(99999).to_s
            allow(GoogleApps::Proxy).to receive(:access_granted?).with(random_id).and_return(true)
          end
          subject do
            post :create, valid_input
          end
          it_behaves_like "failure response"
        end
      end

      context "success scenarios" do
        before(:each) do
          described_class.any_instance.stub(:check_google_access).and_return(true)
          fake_proxy = GoogleApps::EventsInsert.new(fake: true)
          GoogleApps::EventsInsert.stub(:new).and_return(fake_proxy)
        end
        subject do
          post :create, valid_input
        end
        it 'responds with the expected feed' do
          expect(subject).to be_success
          expect(subject.status).to eq(200)
          expect(subject.content_type).to eq("application/json")
          expect(JSON.parse(subject.body)["status"]).to be_true
          expect(JSON.parse(subject.body)["summary"]).to eq("Fancy event")
          expect(JSON.parse(subject.body)["id"]).to be_present
        end
      end

    end

  end

end
