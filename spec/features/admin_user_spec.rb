require "spec_helper"

feature "authentication" do

  before do
    User::Auth.new_or_update_superuser! "238382"
  end

  scenario "Successful admin access" do
    Cache::UserCacheWarmer.stub(:warm).and_return(nil)
    login_with_cas "238382"
    visit "/dashboard"
    expect(Capybara.current_session.driver.request.cookies['reauthenticated']).to eq nil
    visit "/ccadmin"
    expect(current_path).to eq "/ccadmin"
    expect(Capybara.current_session.driver.request.cookies['reauthenticated']).to eq 'true'
    expect(page).to have_content 'Site Administration'
  end
end
