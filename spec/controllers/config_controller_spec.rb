describe ConfigController do

  context "unauthenticated" do
    before do
      get :get
      @json_response = JSON.parse(response.body)
    end

    it "should return a JSON feed" do
      assert_response :success
      response.status.should == 200
      @json_response.is_a?(Hash).should be_truthy
    end

    it "should contain the correct properties" do
      ['applicationVersion', 'clientHostname', 'googleAnalyticsId', 'sentryUrl', 'csrfToken', 'csrfParam'].each do |property|
        @json_response[property].present?.should be_truthy
        @json_response[property].is_a?(String).should be_truthy
      end
    end
  end

  context "authenticated" do
    let(:random_id) { rand(99999).to_s }

    before do
      session['user_id'] = random_id

      get :get
      @json_response = JSON.parse(response.body)
    end

    it "should contain the uid property" do
      @json_response['uid'].present?.should be_truthy
      @json_response['uid'].is_a?(String).should be_truthy
    end
  end

end
