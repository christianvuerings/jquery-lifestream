require "spec_helper"

describe "Course Provisioning Job Request" do

  it "creates a background job" do
    Calcentral::USER_CACHE_WARMER.stub(:warm).and_return(nil)
    UserAuth.stub(:is_superuser?, '238382').and_return(true)
    open_session
    login_with_cas '238382'

    puts "session: #{session.inspect}"

    instructor_id = "1234"       # represents UID for instructor / teacher creating courses
    ccns = ["12345", "12348"]    # represents the course control numbers associated with each course section
    term_slug = "fall-2013"      # represents the term for the course being created

    post canvas_course_create_path, ccns: ccns, instructor_id: instructor_id, term_slug: term_slug
    # expect(response).to be_success
    # json_response = JSON.parse(response.body)
    puts "response.headers: #{response.headers.inspect}"
    puts "response.body: #{response.body.inspect}"

    # get "/widgets/new"
    # expect(response).to render_template(:new)
    # post "/widgets", :widget => {:name => "My Widget"}
    # expect(response).to redirect_to(assigns(:widget))
    # follow_redirect!
    # expect(response).to render_template(:show)
    # expect(response.body).to include("Widget was successfully created.")
  end

end
