require "spec_helper"

describe CanvasCourseGradeExportController do

  let(:course_grades) do
    [
      {'uid' => '1001', 'grade' => 84.9, 'comment' => ''},
      {'uid' => '1002', 'grade' => 45.9, 'comment' => ''},
      {'uid' => '1003', 'grade' => 78.2, 'comment' => ''},
      {'uid' => '1004', 'grade' => 95.7, 'comment' => ''},
    ]
  end

  before do
    session[:user_id] = "4868640"
    session[:canvas_user_id] = "43232321"
    session[:canvas_course_id] = "1164764"
    allow_any_instance_of(Canvas::CoursePolicy).to receive(:can_export_grades?).and_return(true)
    allow_any_instance_of(Canvas::CourseUsers).to receive(:course_grades).and_return(course_grades)
  end

  describe "when serving grade export option data" do
    let(:official_course_sections) do
      [
        {"dept_name"=>"CHEM", "catalog_id"=>"3BL", "term_yr"=>"2014", "term_cd"=>"C", "course_cntl_num"=>"22280", "primary_secondary_cd"=>"P", "section_num"=>"001", "instruction_format"=>"LEC"},
        {"dept_name"=>"CHEM", "catalog_id"=>"3BL", "term_yr"=>"2014", "term_cd"=>"C", "course_cntl_num"=>"22345", "primary_secondary_cd"=>"S", "section_num"=>"208", "instruction_format"=>"LAB"}
      ]
    end
    let(:grade_types) { {:number_grades_present => true, :letter_grades_present => false} }
    let(:section_terms) { [{:term_cd => 'C', :term_yr => '2014'}, {:term_cd => 'D', :term_yr => '2015'}] }
    before do
      allow_any_instance_of(Canvas::Egrades).to receive(:official_sections).and_return(official_course_sections)
      allow_any_instance_of(Canvas::Egrades).to receive(:grade_types_present).and_return(grade_types)
      allow_any_instance_of(Canvas::Egrades).to receive(:section_terms).and_return(section_terms)
    end

    it_should_behave_like "an endpoint" do
      let(:make_request) { get :export_options, :format => :csv }
      let(:error_text) { "Something went wrong" }
      before { allow_any_instance_of(Canvas::Egrades).to receive(:official_sections).and_raise(RuntimeError, error_text) }
    end

    it_should_behave_like "an authenticated endpoint" do
      let(:make_request) { get :export_options, :format => :csv }
    end

    it "provides official course sections" do
      get :export_options
      expect(response.status).to eq(200)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an_instance_of Hash
      official_sections = json_response['official_sections']
      expect(official_sections).to be_an_instance_of Array
      expect(official_sections.count).to eq 2
      expect(official_sections[0]['course_cntl_num']).to eq "22280"
      expect(official_sections[1]['course_cntl_num']).to eq "22345"
    end

    it "provides exported grade type states" do
      get :export_options
      expect(response.status).to eq(200)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an_instance_of Hash
      grade_types_present = json_response['grade_types_present']
      expect(grade_types_present).to be_an_instance_of Hash
      expect(grade_types_present['number_grades_present']).to eq true
      expect(grade_types_present['letter_grades_present']).to eq false
    end

    it "provides official section terms existing within course" do
      get :export_options
      expect(response.status).to eq(200)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an_instance_of Hash
      section_terms = json_response['section_terms']
      expect(section_terms.count).to eq 2
      expect(section_terms[0]['term_cd']).to eq "C"
      expect(section_terms[0]['term_yr']).to eq "2014"
      expect(section_terms[1]['term_cd']).to eq "D"
      expect(section_terms[1]['term_yr']).to eq "2015"
    end
  end

  describe "when serving egrades download" do

    it_should_behave_like "an endpoint" do
      let(:make_request) { get :download_egrades_csv, :format => :csv }
      let(:error_text) { "Something went wrong" }
      before { allow_any_instance_of(Canvas::Egrades).to receive(:official_student_grades).and_raise(RuntimeError, error_text) }
    end

    it_should_behave_like "an authenticated endpoint" do
      let(:make_request) { get :download_egrades_csv, :format => :csv }
    end

    context "when the canvas course id is not present in the session" do
      before { session[:canvas_course_id] = nil }
      it "returns 403 error" do
        get :download_egrades_csv, :format => :csv
        expect(response.status).to eq(403)
        expect(response.body).to eq " "
      end
    end

    context "when user is not authorized to download egrades csv" do
      before { allow_any_instance_of(Canvas::CoursePolicy).to receive(:can_export_grades?).and_return(false) }
      it "returns 403 error" do
        get :download_egrades_csv, :format => :csv
        expect(response.status).to eq(403)
        expect(response.body).to eq " "
      end
    end

    context "when user is authorized to download egrades csv" do
      let(:csv_string) { "uid,grade,comment\n872584,F,\"\"\n4000123,B,\"\"\n872527,A+,\"\"\n872529,D-,\"\"\n" }
      before { allow_any_instance_of(Canvas::Egrades).to receive(:official_student_grades_csv).and_return(csv_string) }
      it "raises exception if term code not provided" do
        get :download_egrades_csv, :format => :csv, :term_yr => '2014', :ccn => '1234'
        expect(response.status).to eq(400)
        expect(response.body).to eq "term_cd required"
      end

      it "raises exception if term year not provided" do
        get :download_egrades_csv, :format => :csv, :term_cd => 'D', :ccn => '1234'
        expect(response.status).to eq(400)
        expect(response.body).to eq "term_yr required"
      end

      it "raises exception if course control number not provided" do
        get :download_egrades_csv, :format => :csv, :term_cd => 'D', :term_yr => '2014'
        expect(response.status).to eq(400)
        expect(response.body).to eq "ccn required"
      end

      it "serves egrades csv file download" do
        get :download_egrades_csv, :format => :csv, :term_cd => 'D', :term_yr => '2014', :ccn => '1234'
        expect(response.status).to eq(200)
        expect(response.headers['Content-Type']).to eq 'text/csv'
        expect(response.headers['Content-Disposition']).to eq "attachment; filename=course_1164764_grades.csv"
        expect(response.body).to be_an_instance_of String
        response_csv = CSV.parse(response.body, {headers: true})
        expect(response_csv.count).to eq 4
        response_csv.each do |user_grade|
          expect(user_grade).to be_an_instance_of CSV::Row
          expect(user_grade['uid']).to be_an_instance_of String
          expect(user_grade['grade']).to be_an_instance_of String
          expect(user_grade['comment']).to be_an_instance_of String
        end

        expect(response_csv[0]['uid']).to eq "872584"
        expect(response_csv[0]['grade']).to eq "F"
        expect(response_csv[0]['comment']).to eq ""

        expect(response_csv[1]['uid']).to eq "4000123"
        expect(response_csv[1]['grade']).to eq "B"
        expect(response_csv[1]['comment']).to eq ""

        expect(response_csv[2]['uid']).to eq "872527"
        expect(response_csv[2]['grade']).to eq "A+"
        expect(response_csv[2]['comment']).to eq ""

        expect(response_csv[3]['uid']).to eq "872529"
        expect(response_csv[3]['grade']).to eq "D-"
        expect(response_csv[3]['comment']).to eq ""
      end
    end

  end

end
