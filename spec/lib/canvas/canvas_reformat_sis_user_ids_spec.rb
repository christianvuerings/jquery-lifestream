require "spec_helper"

describe CanvasReformatSisUserIds do
  before do
    @fake_users_report_proxy = CanvasUsersReportProxy.new({fake: true})
  end

  it "should extract campus-integrated user IDs from full Canvas report" do
    CanvasUsersReportProxy.stub(:new).and_return(@fake_users_report_proxy)
    # Test our assumption about the test data.
    includes_non_numeric_login_id = false
    @fake_users_report_proxy.get_csv.each do |user|
      if user['login_id'] == 'canvassupport'
        includes_non_numeric_login_id = true
        break
      end
    end
    includes_non_numeric_login_id.should be_true
    id_map = CanvasReformatSisUserIds.new.fetch_canvas_user_id_map
    id_map['211159'][:canvas_user_id].blank?.should be_false
    id_map['211159'][:sis_user_id].blank?.should be_false
    id_map['canvassupport'].should be_nil
  end

  it "should derive the fancy sis_user_id from campus data" do
    Settings.canvas_proxy.stub(:mixed_sis_user_id).and_return(true)
    worker = CanvasReformatSisUserIds.new
    worker.derive_sis_user_id(
        {
            'ldap_uid' => 10,
            'student_id' => 20,
            'affiliations' => 'AFFILIATE-TYPE-GENERAL,EMPLOYEE-STATUS-EXPIRED,STUDENT-STATUS-EXPIRED'
        }
    ).should == 'UID:10'
    worker.derive_sis_user_id(
        {
            'ldap_uid' => 11,
            'student_id' => 21,
            'affiliations' => 'AFFILIATE-TYPE-GENERAL,EMPLOYEE-STATUS-EXPIRED,STUDENT-STATUS-EXPIRED'
        }
    ).should == 'UID:11'
    worker.derive_sis_user_id(
        {
            'ldap_uid' => 12,
            'student_id' => 22,
            'affiliations' => 'STUDENT-TYPE-REGISTERED,EMPLOYEE-TYPE-ACADEMIC'
        }
    ).should == '22'
    worker.derive_sis_user_id(
        {
            # This shouldn't happen, but we don't want to accidentally create a blank sis_user_id.
            'ldap_uid' => 13,
            'affiliations' => 'STUDENT-TYPE-REGISTERED,EMPLOYEE-TYPE-STAFF'
        }
    ).should == 'UID:13'
    worker.derive_sis_user_id(
        {
            'ldap_uid' => 14,
            'student_id' => 24,
            'affiliations' => 'EMPLOYEE-TYPE-STAFF,STUDENT-TYPE-NOT REGISTERED'
        }
    ).should == '24'
  end

  it "should be able to roll back to the simple sis_user_id" do
    Settings.canvas_proxy.stub(:mixed_sis_user_id).and_return(nil)
    worker = CanvasReformatSisUserIds.new
    worker.derive_sis_user_id(
        {
            'ldap_uid' => 10,
            'student_id' => 20,
            'affiliations' => 'AFFILIATE-TYPE-GENERAL,EMPLOYEE-STATUS-EXPIRED,STUDENT-STATUS-EXPIRED'
        }
    ).should == '10'
    worker.derive_sis_user_id(
        {
            # This shouldn't happen, but we don't want to accidentally create a blank sis_user_id.
            'ldap_uid' => 13,
            'student_id' => 23,
            'affiliations' => 'STUDENT-TYPE-REGISTERED,EMPLOYEE-TYPE-STAFF'
        }
    ).should == '13'
    worker.derive_sis_user_id(
        {
            'ldap_uid' => 14,
            'student_id' => 24,
            'affiliations' => 'EMPLOYEE-TYPE-STAFF,STUDENT-TYPE-NOT REGISTERED'
        }
    ).should == '14'
  end

  it "should find and modify the correct user login record" do
    canvas_user_id = rand(99999)
    matching_login_id = rand(99999)
    new_sis_user_id = "UID:#{rand(99999)}"
    old_id = rand(99999).to_s
    canvas_logins_response = double()
    canvas_logins_response.stub(:status).and_return(200)
    canvas_logins_response.stub(:body).and_return(
        [
            {
                account_id: 90242,
                id: matching_login_id,
                sis_user_id: old_id,
                unique_id: old_id,
                user_id: canvas_user_id
            },
            {
                account_id: 90242,
                id: rand(99999),
                sis_user_id: nil,
                unique_id: "test-#{rand(99999)}",
                user_id: canvas_user_id
            }
        ].to_json
    )
    fake_logins_proxy = double()
    fake_logins_proxy.should_receive(:user_logins).with(canvas_user_id).and_return(canvas_logins_response)
    fake_logins_proxy.should_receive(:change_sis_user_id).with(matching_login_id, new_sis_user_id).and_return(
        double().stub(:status).and_return(200)
    )
    CanvasLoginsProxy.stub(:new).and_return(fake_logins_proxy)
    worker = CanvasReformatSisUserIds.new
    worker.change_sis_user_id(canvas_user_id, new_sis_user_id)
  end

end
