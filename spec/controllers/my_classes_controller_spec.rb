require "spec_helper"
require "open-uri"

describe MyClassesController do

  before(:each) do
    @user_id = rand(99999).to_s
    @valid_ccns = ["41623"]
    @valid_slug = "fall-2013"
    @invalid_ccns = ["12345"]
    @invalid_slug = "fall-2010"
  end

  it "should be an empty course sites feed on non-authenticated user" do
    get :get_feed
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response.should == {}
  end

  it "should be an non-empty course feed on authenticated user" do
    MyClasses.any_instance.stub(:get_feed).and_return(
      [{course_code: "PLEO 22",
      id: "750027",
      emitter: CanvasProxy::APP_NAME}])
    session[:user_id] = @user_id
    get :get_feed
    json_response = JSON.parse(response.body)
    json_response.size.should == 1
    json_response[0]["course_code"].should == "PLEO 22"
  end

  it "should return success response 200 when bkstr site is available" do
    url = "http://www.bkstr.com"
    response = open(url)
    response.status[0].should == "200"
  end

  it "should return success response 200 when book information is available" do
    ccn = "41623"
    term = "2013D"
    url = "http://www.bkstr.com/webapp/wcs/stores/servlet/booklookServlet?bookstore_id-1=554&term_id-1=#{term}&crn-1=#{ccn}"
    response = open(url)
    response.status[0].should == "200"
  end

  it "should be an non-empty textbook feed for valid ccns and terms having textbook" do
    MyClasses.any_instance.stub(:get_books).with(@valid_ccns, @valid_slug)
    get :get_books, ccns: @valid_ccns, slug: @valid_slug
    json_response = JSON.parse(response.body)
    json_response.size.should == 4
    json_response["required_books"]["type"].should == "Required"
    json_response["recommended_books"]["type"].should == "Recommended"
    json_response["optional_books"]["type"].should == "Optional"
    json_response["has_books"].should == true
    json_response["required_books"]["books"][0]["title"].should == "Basic Statistics"
    json_response["required_books"]["books"][0]["isbn"].length.should satisfy{|l| [10, 13].include?(l)}

    image_url = json_response["required_books"]["books"][0]["image"]
    response = open(image_url)
    response.status[0].should == "200"
  end

  it "should return false for has_books when the ccn and term does not have textbooks" do
    MyClasses.any_instance.stub(:get_books).with(@invalid_ccns, @invalid_slug)
    get :get_books, ccns: @invalid_ccns, slug: @invalid_slug
    json_response = JSON.parse(response.body)
    json_response.size.should == 4
    json_response["has_books"].should == false
  end


end
