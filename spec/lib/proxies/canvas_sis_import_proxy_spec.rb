require "spec_helper"

describe "CampusSisImportProxy" do

  it "should get the status of an existing import" do
    fake_proxy = CanvasSisImportProxy.new({fake: true})

    status = fake_proxy.import_status("5842657")
    status["progress"].should == 100
    status["workflow_state"].should == "imported"

    fake_proxy.import_was_successful?(status).should be_true
  end

end
