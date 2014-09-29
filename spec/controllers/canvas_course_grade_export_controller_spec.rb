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

  describe "when serving egrades download" do

    it_should_behave_like "an endpoint" do
      let(:make_request) { get :download_egrades_csv, :format => :csv }
      let(:error_text) { "Something went wrong" }
      before { allow_any_instance_of(Canvas::CourseUsers).to receive(:course_grades_csv).and_raise(RuntimeError, error_text) }
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
      it "serves egrades csv file download" do
        get :download_egrades_csv, :format => :csv
        expect(response.status).to eq(200)
        expect(response.headers['Content-Type']).to eq 'text/csv'
        expect(response.headers['Content-Disposition']).to eq "attachment; filename=course_1164764_grades.csv"
        expect(response.body).to be_an_instance_of String
        response_csv = CSV.parse(response.body, {headers: true})
        expect(response_csv.count).to eq 6
        response_csv.each do |user_grade|
          expect(user_grade).to be_an_instance_of CSV::Row
          expect(user_grade['uid']).to be_an_instance_of String
          expect(user_grade['grade']).to be_an_instance_of String
          expect(user_grade['comment']).to be_an_instance_of String
        end

        expect(response_csv[0]['uid']).to eq "4000123"
        expect(response_csv[0]['grade']).to eq "34.9"
        expect(response_csv[0]['comment']).to eq ""

        expect(response_csv[1]['uid']).to eq "4000169"
        expect(response_csv[1]['grade']).to eq "57.3"
        expect(response_csv[1]['comment']).to eq ""

        expect(response_csv[2]['uid']).to eq "4000309"
        expect(response_csv[2]['grade']).to eq ""
        expect(response_csv[2]['comment']).to eq ""

        expect(response_csv[5]['uid']).to eq "4000272"
        expect(response_csv[5]['grade']).to eq "10.5"
        expect(response_csv[5]['comment']).to eq ""
      end
    end

  end

end
