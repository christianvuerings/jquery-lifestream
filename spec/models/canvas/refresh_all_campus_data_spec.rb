require "spec_helper"

describe Canvas::RefreshAllCampusData do

  let(:current_sis_term_ids)                    { ["TERM:2013-D", "TERM:2014-B"] }
  subject { Canvas::RefreshAllCampusData.new('incremental') }

  before do
    Canvas::Proxy.stub(:current_sis_term_ids).and_return(current_sis_term_ids)
    frozen_moment_in_time = Time.at(1388563200).to_datetime
    DateTime.stub(:now).and_return(frozen_moment_in_time)
  end

  it "establishes the csv import files" do
    expect(subject.users_csv_filename).to be_an_instance_of String
    expect(subject.users_csv_filename).to eq "tmp/canvas/canvas-2014-01-01-users-incremental.csv"
    expect(subject.term_to_memberships_csv_filename).to be_an_instance_of Hash
    expect(subject.term_to_memberships_csv_filename['TERM:2013-D']).to eq "tmp/canvas/canvas-2014-01-01-TERM_2013-D-enrollments-incremental.csv"
    expect(subject.term_to_memberships_csv_filename['TERM:2014-B']).to eq "tmp/canvas/canvas-2014-01-01-TERM_2014-B-enrollments-incremental.csv"
  end

  it "makes calls to each step of refresh in proper order" do
    subject.should_receive(:make_csv_files).ordered.and_return(true)
    subject.should_receive(:import_csv_files).ordered.and_return(true)
    subject.run
  end

  describe '#make_csv_files' do
    it "should send call to populate incremental update csv for users and enrollments" do
      Canvas::MaintainUsers.any_instance.should_receive(:refresh_existing_user_accounts).once.and_return(nil)
      expect_any_instance_of(Canvas::RefreshAllCampusData).to receive(:refresh_existing_term_sections).twice.and_return(nil)
      subject.make_csv_files
    end
  end

  describe '#refresh_existing_term_sections' do
    let(:ccn) { "#{random_id}" }
    let(:canvas_term_sections_csv_string) do
      [
        'canvas_section_id,section_id,canvas_course_id,course_id,name,status,start_date,end_date,canvas_account_id,account_id',
        "#{ccn}2,SEC:2014-B-2#{ccn},#{random_id},CRS:#{ccn},DIS 101,active,,,105300,ACCT:LAW",
        "#{random_id},,#{random_id},CRS:#{ccn},INFORMAL 2,active,,,105300,ACCT:EDUC",
        "#{random_id},SEC:2014-B-#{random_id},#{random_id},,LAB 201,active,,,105300,ACCT:EDUC",
        "#{ccn}1,SEC:2014-B-1#{ccn},#{random_id},CRS:#{ccn},DIS 102,active,,,105300,ACCT:LAW"
      ].join("\n")
    end
    let(:canvas_term_sections_csv_table) { CSV.parse(canvas_term_sections_csv_string, {headers: true}) }
    let(:mock_worker) { double }
    before do
      allow_any_instance_of(Canvas::SectionsReport).to receive(:get_csv).and_return(canvas_term_sections_csv_table)
      expect(Canvas::IncrementalEnrollments).to receive(:new).and_return(mock_worker)
    end

    context 'when a mix of primary and secondary sections' do
      before do
        allow(CampusOracle::Queries).to receive(:get_sections_from_ccns).with('2014', 'B', ["1#{ccn}", "2#{ccn}"]).and_return([
          {'course_cntl_num' => "1#{ccn}", 'primary_secondary_cd' => 'P'},
          {'course_cntl_num' => "2#{ccn}", 'primary_secondary_cd' => 'S'}
        ])
      end
      it 'assigns TA role for secondary sections' do
        expect(mock_worker).to receive(:refresh_enrollments_in_section).with(
          Canvas::Proxy.sis_section_id_to_ccn_and_term("SEC:2014-B-1#{ccn}"),
          "CRS:#{ccn}", "SEC:2014-B-1#{ccn}", 'teacher', "#{ccn}1", 'enrollments_csv', 'known_users', 'users_csv'
        ).ordered.and_return(nil)
        expect(mock_worker).to receive(:refresh_enrollments_in_section).with(
          Canvas::Proxy.sis_section_id_to_ccn_and_term("SEC:2014-B-2#{ccn}"),
          "CRS:#{ccn}", "SEC:2014-B-2#{ccn}", 'ta', "#{ccn}2", 'enrollments_csv', 'known_users', 'users_csv'
        ).ordered.and_return(nil)
        subject.refresh_existing_term_sections('TERM:2014-B', 'enrollments_csv', 'known_users', 'users_csv')
      end
    end

    context 'when all secondary sections' do
      before do
        allow(CampusOracle::Queries).to receive(:get_sections_from_ccns).with('2014', 'B', ["1#{ccn}", "2#{ccn}"]).and_return([
          {'course_cntl_num' => "1#{ccn}", 'primary_secondary_cd' => 'S'},
          {'course_cntl_num' => "2#{ccn}", 'primary_secondary_cd' => 'S'}
        ])
      end
      it 'assigns teacher role for secondary sections' do
        expect(mock_worker).to receive(:refresh_enrollments_in_section).with(
          Canvas::Proxy.sis_section_id_to_ccn_and_term("SEC:2014-B-1#{ccn}"),
          "CRS:#{ccn}", "SEC:2014-B-1#{ccn}", 'teacher', "#{ccn}1", 'enrollments_csv', 'known_users', 'users_csv'
        ).ordered.and_return(nil)
        expect(mock_worker).to receive(:refresh_enrollments_in_section).with(
          Canvas::Proxy.sis_section_id_to_ccn_and_term("SEC:2014-B-2#{ccn}"),
          "CRS:#{ccn}", "SEC:2014-B-2#{ccn}", 'teacher', "#{ccn}2", 'enrollments_csv', 'known_users', 'users_csv'
        ).ordered.and_return(nil)
        subject.refresh_existing_term_sections('TERM:2014-B', 'enrollments_csv', 'known_users', 'users_csv')
      end
    end

  end

end
