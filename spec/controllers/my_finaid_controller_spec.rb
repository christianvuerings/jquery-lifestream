require 'spec_helper'

describe MyFinaidController do

  before(:each) do
    @user_id = rand(99999).to_s
  end

  it 'should be an empty feed on non-authenticated user' do
    get :get_feed
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response.should == {}
  end

  it 'should be an non-empty feed on authenticated user' do
    Finaid::Merged.any_instance.stub(:get_feed).and_return(
      [{awards: 'bar'}])
    session['user_id'] = @user_id
    get :get_feed
    json_response = JSON.parse(response.body)
    json_response.size.should == 1
  end

end
