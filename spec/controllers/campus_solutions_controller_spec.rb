require "spec_helper"

describe CampusSolutionsController do

  before(:each) do
    @user_id = rand(99999).to_s
  end

  it 'should be an empty country feed on non-authenticated user' do
    get :country
    json = JSON.parse(response.body)
    expect(json).to eq({})
  end

  it 'should be an non-empty countries feed on authenticated user' do
    session['user_id'] = @user_id
    get :country
    json = JSON.parse(response.body)
    expect(json['statusCode']).to eq 200
    expect(json['feed']['countries']).to be
  end

end
