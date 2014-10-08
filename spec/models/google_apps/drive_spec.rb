require "spec_helper"

describe GoogleApps::DriveList do

  begin
    @random_id = rand(99999).to_s
  end

  it "Should return a valid list of drive files" do
    drive_list_proxy = GoogleApps::DriveList.new :fake => true
    drive_list_proxy.class.api.should == "drive"
    response = drive_list_proxy.drive_list
    response.kind_of?(Enumerable).should be_truthy
    response.each do |response_page|
      response_page.status.should == 200
      response_page.data["kind"].should == "drive#fileList"
      response_page.data["items"].kind_of?(Array).should be_truthy
    end
  end

end
