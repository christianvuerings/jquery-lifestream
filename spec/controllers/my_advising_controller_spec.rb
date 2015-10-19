describe MyAdvisingController do

  it 'should be an empty advising feed on non-authenticated user' do
    get :get_feed
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response.should == {}
  end

  context 'with an authenticated user' do
    before(:each) do
      Settings.advising_proxy.stub(:fake).and_return(true)
    end
    it 'should be an non-empty advising feed based on fake Oski recorded data' do
      session['user_id'] = '61889'
      get :get_feed
      json_response = JSON.parse(response.body)
      json_response.size.should == 8
      json_response["statusCode"].should == 200
    end
  end
end
