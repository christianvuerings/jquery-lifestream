require "spec_helper"

describe "authentication" do
  it "Test failing authentication" do
    break_cas
    login_with_cas "192517"
    page.status_code.should == 401
    restore_cas "192517"
  end
end
