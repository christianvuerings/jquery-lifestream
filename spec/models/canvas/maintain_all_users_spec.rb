require "spec_helper"

describe Canvas::MaintainAllUsers do

  let(:user_report_csv_string) do
    csv_string = "canvas_user_id,user_id,login_id,first_name,last_name,email,status\n"
    csv_string += "123,22729403,946123,John,Smith,john.smith@berkeley.edu,active\n"
    csv_string += "124,UID:946124,946124,Jane,Smith,janesmith@gmail.com,active\n"
    csv_string += "125,22729405,946125,Charmaine,D'Silva,charmainedsilva@berkeley.edu,active\n"
    csv_string += "126,22729407,946127,Brian,Warner,bwarner@example.com,active"
    csv_string
  end

  # Email addresss changes for Charmaine D'Silva
  # SIS User ID changes for Jane Smith
  let(:sis_active_people) do
    [
      {"ldap_uid"=>"946123", "first_name"=>"John", "last_name"=>"Smith", "email_address"=>"john.smith@berkeley.edu", "student_id"=>"22729403"},
      {"ldap_uid"=>"946124", "first_name"=>"Jane", "last_name"=>"Smith", "email_address"=>"janesmith@gmail.com", "student_id"=>"22729404"},
      {"ldap_uid"=>"946125", "first_name"=>"Charmaine", "last_name"=>"D'Silva", "email_address"=>"charmainedsilva@example.com", "student_id"=>"22729405"},
      {"ldap_uid"=>"946126", "first_name"=>"Dwight", "last_name"=>"Schrute", "email_address"=>"dschrute@schrutefarms.com", "student_id"=>nil},
    ]
  end

  let(:user_report_csv) { CSV.parse(user_report_csv_string, {headers: true}) }
  let(:fake_now_datetime) { DateTime.strptime('2014-07-23T09:00:06+07:00', '%Y-%m-%dT%H:%M:%S%z') }
  let(:new_canvas_user) { {"user_id"=>"UID:946126", "login_id"=>"946126", "password"=>nil, "first_name"=>"Dwight", "last_name"=>"Schrute", "email"=>"dschrute@schrutefarms.com", "status"=>"active"} }

  before do
    allow(DateTime).to receive(:now).and_return(fake_now_datetime)
    allow_any_instance_of(Canvas::UsersReport).to receive(:get_csv).and_return(user_report_csv)
    allow(CampusOracle::Queries).to receive(:get_all_active_people_attributes).and_return(sis_active_people)

    # have to mock the responses due to dependency on Campus Oracle data
    allow(subject).to receive(:derive_sis_user_id).with(sis_active_people[0]).and_return('22729403')
    allow(subject).to receive(:derive_sis_user_id).with(sis_active_people[1]).and_return('22729404')
    allow(subject).to receive(:derive_sis_user_id).with(sis_active_people[2]).and_return('22729405')
    allow(subject).to receive(:derive_sis_user_id).with(sis_active_people[3]).and_return('UID:946126')
  end

  after do
    delete_files_if_exists([
      'tmp/canvas/canvas-2014-07-23_09-00-06-users-report.csv',
      'tmp/canvas/canvas-2014-07-23_09-00-06-sync-all-users.csv'
    ])
  end

  describe "#sync_all_active_users" do
    it "calls user syncing methods in intended order" do
      expect(subject).to receive(:prepare_sis_user_import).ordered.and_return(true)
      expect(subject).to receive(:get_canvas_user_report_file).ordered.and_return(true)
      expect(subject).to receive(:load_active_users).ordered.and_return(true)
      expect(subject).to receive(:process_updated_users).ordered.and_return(true)
      expect(subject).to receive(:process_new_users).ordered.and_return(true)
      sis_user_id_updates = subject.instance_eval { @sis_user_id_updates }
      expect(Canvas::MaintainUsers).to receive(:handle_changed_sis_user_ids).with(sis_user_id_updates).ordered.and_return(true)
      expect(subject).to receive(:import_sis_user_csv).ordered.and_return(true)
      subject.sync_all_active_users
    end
  end

  describe "#prepare_sis_user_import" do
    it "prepares sis user import file" do
      subject.prepare_sis_user_import
      result = subject.instance_eval { @sis_user_import }
      expect(result).to be_an_instance_of CSV
      expect(result.path).to eq "tmp/canvas/canvas-2014-07-23_09-00-06-sync-all-users.csv"
    end
  end

  describe "#get_canvas_user_report_file" do
    it "returns path to file containing canvas user report CSV" do
      result = subject.get_canvas_user_report_file
      expect(result).to be_an_instance_of String
      expect(result).to eq "tmp/canvas/canvas-2014-07-23_09-00-06-users-report.csv"
      expect(File.exists?(result)).to be_true
    end

    it "inserts all users into csv file" do
      result = subject.get_canvas_user_report_file
      expect(result).to be_an_instance_of String
      csv_array = CSV.read("tmp/canvas/canvas-2014-07-23_09-00-06-users-report.csv")
      expect(csv_array[0]).to eq ["canvas_user_id", "user_id", "login_id", "first_name", "last_name", "email", "status"]
      expect(csv_array[1][2]).to eq "946123"
      expect(csv_array[2][2]).to eq "946124"
      expect(csv_array[3][2]).to eq "946125"
    end

    it "returns existing file path if user report already obtained" do
      expect_any_instance_of(Canvas::UsersReport).to receive(:get_csv).once.and_return(user_report_csv)
      result_1 = subject.get_canvas_user_report_file
      expect(result_1).to be_an_instance_of String
      expect(result_1).to eq "tmp/canvas/canvas-2014-07-23_09-00-06-users-report.csv"
      expect(File.exists?(result_1)).to be_true
      result_2 = subject.get_canvas_user_report_file
      expect(result_2).to be_an_instance_of String
      expect(result_2).to eq "tmp/canvas/canvas-2014-07-23_09-00-06-users-report.csv"
      expect(File.exists?(result_2)).to be_true
    end
  end

  describe "#load_active_users" do
    it "generates uid indexed set of active users from sis source" do
      subject.load_active_users
      result = subject.instance_eval { @active_sis_users }
      expect(result).to be_an_instance_of Hash
      expect(result["946123"]).to be_an_instance_of Hash
      expect(result["946124"]).to be_an_instance_of Hash
      expect(result["946125"]).to be_an_instance_of Hash
      expect(result["946126"]).to be_an_instance_of Hash
      expect(result["946123"]['first_name']).to eq "John"
      expect(result["946123"]['last_name']).to eq "Smith"
    end
  end

  describe "#process_updated_users" do
    it "adds updated users to sis user import" do
      expect(subject).to receive(:add_user_to_import).once.with({"user_id"=>"22729405", "login_id"=>"946125", "password"=>nil, "first_name"=>"Charmaine", "last_name"=>"D'Silva", "email"=>"charmainedsilva@example.com", "status"=>"active"})
      subject.load_active_users
      subject.process_updated_users
    end

    it "removes existing users from active users hash" do
      subject.prepare_sis_user_import
      subject.load_active_users
      subject.process_updated_users
      new_users = subject.instance_eval { @active_sis_users }
      expect(new_users).to be_an_instance_of Hash
      expect(new_users.length).to eq 1
      expect(new_users['946126']).to be_an_instance_of Hash
      expect(new_users['946126']['first_name']).to eq "Dwight"
      expect(new_users['946126']['last_name']).to eq "Schrute"
    end

    it "creates set of sis user id updates" do
      subject.prepare_sis_user_import
      subject.load_active_users
      subject.process_updated_users
      sis_user_updates = subject.instance_eval { @sis_user_id_updates }
      expect(sis_user_updates).to be_an_instance_of Hash
      expect(sis_user_updates.length).to eq 1
      expect(sis_user_updates['sis_login_id:946124']).to eq '22729404'
    end
  end

  describe "#process_new_users" do
    it "adds users in active_sis_users hash to sis user import csv" do
      subject.prepare_sis_user_import
      subject.load_active_users
      subject.process_updated_users
      expect(subject).to receive(:add_user_to_import).with(new_canvas_user)
      subject.process_new_users
    end
  end

  describe "#add_user_to_import" do
    it "adds the user to the sis import csv file" do
      subject.prepare_sis_user_import
      sis_import_file = subject.instance_eval { @sis_user_import }
      expect(sis_import_file).to receive(:<<).with(new_canvas_user)
      subject.add_user_to_import(new_canvas_user)
    end
  end

  describe "#import_sis_user_csv" do
    it "imports user csv if users present" do
      subject.prepare_sis_user_import
      subject.add_user_to_import(new_canvas_user)
      expect_any_instance_of(Canvas::SisImport).to receive(:import_users).with("tmp/canvas/canvas-2014-07-23_09-00-06-sync-all-users.csv").and_return(true)
      subject.import_sis_user_csv
    end

    it "does not import user csv if no users present" do
      subject.prepare_sis_user_import
      expect_any_instance_of(Canvas::SisImport).to_not receive(:import_users)
      subject.import_sis_user_csv
    end
  end

end
