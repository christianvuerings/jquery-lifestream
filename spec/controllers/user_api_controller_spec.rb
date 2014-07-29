require "spec_helper"

describe UserApiController do

  it "should not have a logged-in status" do
    get :mystatus
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response["isLoggedIn"].should == false
    json_response["uid"].should be_nil
    json_response["features"].should_not be_nil
  end

  it "should show status for a logged-in user" do
    session[:user_id] = "238382"
    get :mystatus
    json_response = JSON.parse(response.body)
    json_response["isLoggedIn"].should == true
    json_response["uid"].should == "238382"
    json_response["preferred_name"].should_not be_nil
    json_response["features"].should_not be_nil
    visit = User::Visit.where(:uid=>session[:user_id])[0]
    visit.last_visit_at.should_not be_nil
  end

  it "should record first login for a new user" do
    CampusOracle::UserAttributes.stub(:new).and_return(double(get_feed: {
      'person_name' => "Joe Test",
      :roles => {
        :student => true,
        :faculty => false,
        :staff => false
      }
    }))
    session[:user_id] = random_id
    get :mystatus
    json_response = JSON.parse(response.body)
    json_response["firstLoginAt"].should == nil
    get :record_first_login
    response.status.should == 204
    get :mystatus
    json_response = JSON.parse(response.body)
    json_response["firstLoginAt"].should_not be_nil
  end

  describe '#acting_as_uid' do
    let (:user_id) { random_id }
    before do
      session[:user_id] = user_id
      allow(CampusOracle::UserAttributes).to receive(:new).and_return(double(get_feed: {
        'person_name' => "Joe Test",
        :roles => {
          :student => true,
          :faculty => false,
          :staff => false
        }
      }))
    end
    subject do
      get :mystatus
      JSON.parse(response.body)['actingAsUid']
    end
    context 'when normally authenticated' do
      it {should be false}
    end
    context 'when viewing as' do
      let(:original_user_id) { random_id }
      before { session[:original_user_id] = original_user_id }
      it {should eq original_user_id}
    end
    context 'when authenticated by LTI' do
      before { session[:lti_authenticated_only] = true }
      it {should eq 'LTI Authenticated'}
    end
  end

end
