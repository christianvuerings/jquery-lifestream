require "spec_helper"

describe Canvas::PublicAuthorizer do

  let(:canvas_user_id) { rand(99999).to_s }
  let(:spring_2012_instructor_uid) { '238382' }
  let(:summer_2014_instructor_uid) { '904715' }
  let(:current_term_db_row) {{
    'term_yr' => '2014',
    'term_cd' => 'B',
    'term_status_desc' => 'Current Term',
    'term_name' => 'Spring',
    'term_start_date' => Time.gm(2014, 1, 21),
    'term_end_date' => Time.gm(2014, 5, 9)
  }}
  let(:summer_term_db_row) {{
    'term_yr' => '2014',
    'term_cd' => 'C',
    'term_status_desc' => 'Current Summer',
    'term_name' => 'Summer',
    'term_start_date' => Time.gm(2014, 5, 27),
    'term_end_date' => Time.gm(2014, 8, 15)
  }}
  let(:fall_term_db_row) {{
    'term_yr' => '2014',
    'term_cd' => 'D',
    'term_status_desc' => 'Future Term',
    'term_name' => 'Fall',
    'term_start_date' => Time.gm(2014, 8, 28),
    'term_end_date' => Time.gm(2014, 12, 12)
  }}
  let(:current_terms) {
    [
      Berkeley::Term.new(fall_term_db_row),
      Berkeley::Term.new(summer_term_db_row),
      Berkeley::Term.new(current_term_db_row),
    ]
  }
  subject { Canvas::PublicAuthorizer.new(canvas_user_id) }

  describe "#user_currently_teaching?" do
    before do
      allow(Canvas::Proxy).to receive(:canvas_current_terms).and_return(current_terms)
    end

    context "when user is instructing in current canvas terms", if: CampusOracle::Queries.test_data? do
      before { allow_any_instance_of(Canvas::UserProfile).to receive(:login_id).and_return(summer_2014_instructor_uid) }
      its(:user_currently_teaching?) { should be_true }
    end

    context "when user is not instructing in current canvas terms", if: CampusOracle::Queries.test_data? do
      before { allow_any_instance_of(Canvas::UserProfile).to receive(:login_id).and_return(spring_2012_instructor_uid) }
      its(:user_currently_teaching?) { should be_false }
    end

    context "when campus user id is unavailable" do
      before { allow_any_instance_of(Canvas::UserProfile).to receive(:login_id).and_return(nil) }
      its(:user_currently_teaching?) { should be_false }
    end

    context "when response is cached" do
      it "does not make calls to dependent objects" do
        allow_any_instance_of(Canvas::UserProfile).to receive(:login_id).and_return(summer_2014_instructor_uid)
        expect(subject.user_currently_teaching?).to be_true
        expect_any_instance_of(Canvas::UserProfile).to_not receive(:login_id)
        expect(Canvas::Proxy).to_not receive(:canvas_current_terms)
        expect(CampusOracle::Queries).to_not receive(:has_instructor_history?)
        expect(subject.user_currently_teaching?).to be_true
      end
    end
  end

end
