require "spec_helper"

describe "GoogleDriveListProxy" do

  begin
    @random_id = rand(99999).to_s
  end

  it "Should return a valid list of drive files" do
    drive_list_proxy = GoogleDriveListProxy.new :fake => true
    drive_list_proxy.class.api.should == "drive"
    response = drive_list_proxy.drive_list
    response.kind_of?(Enumerable).should be_true
    response.each do |response_page|
      response_page.status.should == 200
      response_page.data["kind"].should == "drive#fileList"
      response_page.data["items"].kind_of?(Array).should be_true
    end
  end

end
