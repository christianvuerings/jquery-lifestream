require "support/canvas_shared_examples"

describe CampusRostersController do

  let(:campus_course_id)  { "compsci-9a-2014-D" }
  let(:user_id)           { rand(99999) }
  let(:student_id)        { rand(99999) }
  let(:roster_feed) do
    {
      :campus_course=>{ :id=>"compsci-9a-2014-D" },
      :sections=>[
        {:id=>"25653", :name=>"COMPSCI 9A SLF 001"}
      ],
      :students=>[
        {:student_id=>"23154487", :first_name=>"Michael", :last_name=>"Scott", :email=>"michael.scott@example.com", :enroll_status=>"E", :section_ccns=>["25653"], :id=>"952576", :login_id=>"952576", :profile_url=>"https://calnet.berkeley.edu/directory/details.pl?uid=952576", :sections=>[{:id=>"25653"}], :photo=>"/campus/compsci-9a-2014-D/photo/952576"},
        {:student_id=>"23154488", :first_name=>"Dwight", :last_name=>"Schrute", :email=>"dk.schrute@example.com", :enroll_status=>"C", :section_ccns=>["25653"], :id=>"952577", :login_id=>"952577", :profile_url=>"https://calnet.berkeley.edu/directory/details.pl?uid=952577", :sections=>[{:id=>"25653"}], :photo=>"/campus/compsci-9a-2014-D/photo/952577"},
        {:student_id=>"23154489", :first_name=>"Toby", :last_name=>"Flenderson", :email=>"toby@example.com", :enroll_status=>"E", :section_ccns=>["25653"], :id=>"952578", :login_id=>"952578", :profile_url=>"https://calnet.berkeley.edu/directory/details.pl?uid=952578", :sections=>[{:id=>"25653"}], :photo=>"/campus/compsci-9a-2014-D/photo/952578"},
      ]
    }
  end
  let(:photo_file) { {:data => '\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x01'} }

  before do
    session['user_id'] = user_id
    allow_any_instance_of(Berkeley::CoursePolicy).to receive(:can_view_roster_photos?).and_return(true)
    allow_any_instance_of(Rosters::Campus).to receive(:get_feed).and_return(roster_feed)
  end

  context "when serving course rosters feed" do

    it_should_behave_like "an api endpoint" do
      before { allow_any_instance_of(Rosters::Campus).to receive(:get_feed_filtered).and_raise(RuntimeError, "Something went wrong") }
      let(:make_request) { get :get_feed, campus_course_id: campus_course_id }
    end

    it_should_behave_like "a user authenticated api endpoint" do
      let(:make_request) { get :get_feed, campus_course_id: campus_course_id }
    end

    it "should return error if user is not authorized" do
      allow_any_instance_of(Berkeley::CoursePolicy).to receive(:can_view_roster_photos?).and_return(false)
      get :get_feed, campus_course_id: campus_course_id
      assert_response(403)
    end

    it "should return json when user is authorized" do
      get :get_feed, campus_course_id: campus_course_id
      assert_response :success
      response_json = JSON.parse(response.body)
      expect(response_json.has_key?('campus_course')).to be_truthy
      expect(response_json.has_key?('sections')).to be_truthy
      expect(response_json.has_key?('students')).to be_truthy
    end
  end

  context 'when serving course rosters csv download' do
    it_should_behave_like "an api endpoint" do
      before { allow_any_instance_of(Rosters::Campus).to receive(:get_csv).and_raise(RuntimeError, "Something went wrong") }
      let(:make_request) { get :get_csv, campus_course_id: campus_course_id, format: :csv }
    end

    it_should_behave_like "a user authenticated api endpoint" do
      let(:make_request) { get :get_csv, campus_course_id: campus_course_id, format: :csv }
    end

    it "should return error if user is not authorized" do
      allow_any_instance_of(Berkeley::CoursePolicy).to receive(:can_view_roster_photos?).and_return(false)
      get :get_csv, campus_course_id: campus_course_id, format: :csv
      assert_response(403)
    end

    it "should return csv file when user is authorized" do
      get :get_csv, campus_course_id: campus_course_id, format: :csv
      assert_response :success
      response_csv = CSV.parse(response.body, {headers: true})
      expect(response_csv.count).to eq 3

      expect(response_csv[0]).to be_an_instance_of CSV::Row
      expect(response_csv[0]['Name']).to eq 'Scott, Michael'
      expect(response_csv[0]['User ID']).to eq '952576'
      expect(response_csv[0]['Student ID']).to eq '23154487'
      expect(response_csv[0]['Email Address']).to eq 'michael.scott@example.com'
      expect(response_csv[0]['Role']).to eq 'Student'

      expect(response_csv[1]).to be_an_instance_of CSV::Row
      expect(response_csv[1]['Name']).to eq 'Schrute, Dwight'
      expect(response_csv[1]['Student ID']).to eq '23154488'
      expect(response_csv[1]['Email Address']).to eq 'dk.schrute@example.com'
      expect(response_csv[1]['Role']).to eq 'Concurrent Student'
    end
  end

  context "when serving course enrollee photo" do
    it_should_behave_like "an api endpoint" do
      before { allow_any_instance_of(Rosters::Campus).to receive(:photo_data_or_file).and_raise(RuntimeError, "Something went wrong") }
      let(:make_request) { get :photo, campus_course_id: campus_course_id, person_id: student_id }
    end

    it_should_behave_like "a user authenticated api endpoint" do
      let(:make_request) { get :photo, campus_course_id: campus_course_id, person_id: student_id }
    end

    it "should return error if user is not authorized" do
      allow_any_instance_of(Berkeley::CoursePolicy).to receive(:can_view_roster_photos?).and_return(false)
      get :photo, campus_course_id: campus_course_id, person_id: student_id
      assert_response(403)
    end

    context "if photo path returned for enrollee" do
      before { allow_any_instance_of(Rosters::Campus).to receive(:photo_data_or_file).and_return(photo_file) }
      it "should return photo" do
        get :photo, campus_course_id: campus_course_id, person_id: student_id
        assert_response :success
      end
    end

  end

end
