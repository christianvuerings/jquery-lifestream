require "spec_helper"

describe GoogleAuthController do
  let(:user_id) { random_id }
  before do
    session[:user_id] = user_id
  end

  describe '#dismiss_reminder' do
    it "should store a dismiss_reminder key-value when there's no token for a user" do
      GoogleApps::Proxy.stub(:access_granted?).with(user_id).and_return(false)
      post :dismiss_reminder, { :format => 'json' }
      response.status.should eq(200)
      json_response = JSON.parse(response.body)
      json_response['result'].should be_true
    end

    it "should not store a dismiss_reminder key-value when there's an existing token" do
      GoogleApps::Proxy.stub(:access_granted?).with(user_id).and_return(true)
      post :dismiss_reminder, { :format => 'json' }
      response.status.should eq(200)
      json_response = JSON.parse(response.body)
      json_response['result'].should be_false
    end
  end

  context 'indirectly authenticated' do
    before do
      allow(GoogleApps::Proxy).to receive(:access_granted?).with(user_id).and_return(true)
      expect(Google::APIClient).to receive(:new).never
    end
    subject do
      post :request_authorization, {}
    end
    context 'viewing as' do
      before do
        session[:original_user_id] = random_id
      end
      it { should_not be_success }
    end
    context 'LTI embedded' do
      before do
        session[:lti_authenticated_only] = true
      end
      it { should_not be_success }
    end
  end

end
