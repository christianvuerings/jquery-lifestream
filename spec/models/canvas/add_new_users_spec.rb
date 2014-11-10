require "spec_helper"
require "set"

describe Canvas::AddNewUsers do

  let(:user_report_csv_string) do
    csv_string = "canvas_user_id,user_id,login_id,first_name,last_name,email,status\n"
    csv_string += "123,22729403,946123,John,Smith,john.smith@berkeley.edu,active\n"
    csv_string += "124,UID:946124,946124,Jane,Smith,janesmith@gmail.com,active\n"
    csv_string += "125,22729405,946125,Charmaine,D'Silva,charmainedsilva@berkeley.edu,active\n"
    csv_string += "126,22729407,946126,Brian,Warner,bwarner@example.com,active"
    csv_string
  end

  # Email addresss changes for Charmaine D'Silva
  # SIS User ID changes for Jane Smith
  let(:sis_active_uids) { ["946122","946123","946124","946125","946126","946127"].to_set }
  let(:sis_active_people) do
    [
      {"ldap_uid"=>"946122", "first_name"=>"Charmaine", "last_name"=>"D'Silva", "email_address"=>"charmainedsilva@example.com", "student_id"=>"22729405"},
      {"ldap_uid"=>"946127", "first_name"=>"Dwight", "last_name"=>"Schrute", "email_address"=>"dschrute@schrutefarms.com", "student_id"=>nil},
    ]
  end

  let(:user_report_csv) { CSV.parse(user_report_csv_string, {headers: true}) }
  let(:fake_now_datetime) { DateTime.strptime('2014-07-23T09:00:06+07:00', '%Y-%m-%dT%H:%M:%S%z') }
  let(:new_canvas_users) do
    [
      {"user_id"=>"22729405", "login_id"=>"946122", "password"=>nil, "first_name"=>"Charmaine", "last_name"=>"D'Silva", "email"=>"charmainedsilva@example.com", "status"=>"active"},
      {"user_id"=>"UID:946127", "login_id"=>"946127", "password"=>nil, "first_name"=>"Dwight", "last_name"=>"Schrute", "email"=>"dschrute@schrutefarms.com", "status"=>"active"}
    ]
  end

  before do
    allow(DateTime).to receive(:now).and_return(fake_now_datetime)
    allow_any_instance_of(Canvas::UsersReport).to receive(:get_csv).and_return(user_report_csv)
    allow(CampusOracle::Queries).to receive(:get_all_active_people_uids).and_return(sis_active_uids)
    allow(CampusOracle::Queries).to receive(:get_basic_people_attributes).and_return(sis_active_people)

    # have to mock the responses due to dependency on Campus Oracle data
    allow(subject).to receive(:derive_sis_user_id).with(sis_active_people[0]).and_return('22729405')
    allow(subject).to receive(:derive_sis_user_id).with(sis_active_people[1]).and_return('UID:946127')
  end

  after do
    delete_files_if_exists([
      'tmp/canvas/canvas-2014-07-23_09-00-06-users-report.csv',
      'tmp/canvas/canvas-2014-07-23_09-00-06-sync-all-users.csv'
    ])
  end

  describe "#sync_new_active_users" do
    it "calls user syncing methods in intended order" do
      expect(subject).to receive(:prepare_sis_user_import).ordered.and_return(true)
      expect(subject).to receive(:get_canvas_user_report_file).ordered.and_return(true)
      expect(subject).to receive(:load_new_active_users).ordered.and_return(true)
      expect(subject).to receive(:process_new_users).ordered.and_return(true)
      expect(subject).to receive(:import_sis_user_csv).ordered.and_return(true)
      subject.sync_new_active_users
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
      expect(File.exists?(result)).to be_truthy
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
      expect(File.exists?(result_1)).to be_truthy
      result_2 = subject.get_canvas_user_report_file
      expect(result_2).to be_an_instance_of String
      expect(result_2).to eq "tmp/canvas/canvas-2014-07-23_09-00-06-users-report.csv"
      expect(File.exists?(result_2)).to be_truthy
    end
  end

  describe "#load_new_active_users" do
    it "loads new active users into array" do
      expect(CampusOracle::Queries).to receive(:get_basic_people_attributes).with(['946122','946127']).and_return(sis_active_people)
      result = subject.load_new_active_users
      loaded_users = subject.instance_eval { @new_active_sis_users }
      expect(loaded_users).to be_an_instance_of Array
      expect(loaded_users.count).to eq 2
      expect(loaded_users[0]).to be_an_instance_of Hash
      expect(loaded_users[1]).to be_an_instance_of Hash
      expect(loaded_users[0]['ldap_uid']).to eq "946122"
      expect(loaded_users[0]['first_name']).to eq "Charmaine"
      expect(loaded_users[1]['ldap_uid']).to eq "946127"
      expect(loaded_users[1]['first_name']).to eq "Dwight"
    end

    it "loads empty array when no new active users" do
      allow(subject).to receive(:new_active_user_uids).and_return([])
      expect(CampusOracle::Queries).to_not receive(:get_basic_people_attributes)
      result = subject.load_new_active_users
      loaded_users = subject.instance_eval { @new_active_sis_users }
      expect(loaded_users).to eq []
    end
  end

  describe "#process_new_users" do
    it "adds users in new_active_sis_user_uids set to sis user import csv" do
      subject.prepare_sis_user_import
      subject.get_canvas_user_report_file
      subject.load_new_active_users
      expect(subject).to receive(:add_user_to_import).with(new_canvas_users[0]).ordered.and_return(true)
      expect(subject).to receive(:add_user_to_import).with(new_canvas_users[1]).ordered.and_return(true)
      subject.process_new_users
    end
  end

  describe "#import_sis_user_csv" do
    it "imports user csv if users present" do
      subject.prepare_sis_user_import
      subject.add_user_to_import(new_canvas_users[0])
      expect_any_instance_of(Canvas::SisImport).to receive(:import_users).with("tmp/canvas/canvas-2014-07-23_09-00-06-sync-all-users.csv").and_return(true)
      subject.import_sis_user_csv
    end

    it "does not import user csv if no users present" do
      subject.prepare_sis_user_import
      expect_any_instance_of(Canvas::SisImport).to_not receive(:import_users)
      subject.import_sis_user_csv
    end
  end

  describe "#new_active_user_uids" do
    it "returns array new active user UIDs" do
      result = subject.new_active_user_uids
      expect(result).to be_an_instance_of Array
      expect(result.include?("946122")).to be_truthy
      expect(result.include?("946127")).to be_truthy
      expect(result.include?("946123")).to be_falsey
      expect(result.include?("946124")).to be_falsey
      expect(result.include?("946125")).to be_falsey
      expect(result.include?("946126")).to be_falsey
    end
  end

  describe "#split_uid_array" do
    it "returns argument in array when less than 1000 uids" do
      input_array = (2051..3050).to_a
      expect(input_array.count).to eq 1000
      result = subject.split_uid_array(input_array)
      expect(result.count).to eq 1
      expect(result[0]).to eq input_array

      input_array = (2051..2061).to_a
      expect(input_array.count).to eq 11
      result = subject.split_uid_array(input_array)
      expect(result.count).to eq 1
      expect(result[0]).to eq input_array
    end

    it "returns array split into groups of 1000 or less uids" do
      input_array = (2051..5025).to_a
      result = subject.split_uid_array(input_array)
      expect(result).to be_an_instance_of Array
      expect(result.count).to eq 3
      expect(result[0].count).to eq 1000
      expect(result[1].count).to eq 1000
      expect(result[2].count).to eq 975

      input_array = (2051..4080).to_a
      result = subject.split_uid_array(input_array)
      expect(result).to be_an_instance_of Array
      expect(result.count).to eq 3
      expect(result[0].count).to eq 1000
      expect(result[1].count).to eq 1000
      expect(result[2].count).to eq 30
    end
  end

  describe "#add_user_to_import" do
    it "adds the user to the sis import csv file" do
      subject.prepare_sis_user_import
      sis_import_file = subject.instance_eval { @sis_user_import }
      expect(sis_import_file).to receive(:<<).with(new_canvas_users[0])
      subject.add_user_to_import(new_canvas_users[0])
    end
  end

end
