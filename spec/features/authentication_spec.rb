require "spec_helper"

feature "authentication" do
  scenario "Failing authentication" do
    original_logger = OmniAuth.config.logger

    begin
      OmniAuth.config.logger = Logger.new "/dev/null"
      break_cas
      login_with_cas "192517"
      page.status_code.should == 401
      restore_cas "192517"
    ensure
      OmniAuth.config.logger = original_logger
    end
  end
end
