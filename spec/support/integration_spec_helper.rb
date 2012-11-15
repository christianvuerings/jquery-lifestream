module IntegrationSpecHelper
  def login_with_cas(user)
    currentAuth = OmniAuth.config.mock_auth[:cas]
    unless currentAuth.is_a?(Symbol)
      OmniAuth.config.mock_auth[:cas] = OmniAuth::AuthHash.new(
        {
          :provider => 'cas',
          :uid => user
        })
    end
    visit "/login"
  end

  def logout_of_cas
    visit '/logout'
    Capybara.reset_sessions!
  end

  def break_cas
    OmniAuth.config.mock_auth[:cas] = :invalid_credentials
  end

  def restore_cas(user)
    OmniAuth.config.mock_auth[:cas] = OmniAuth::AuthHash.new(
      {
        :provider => 'cas',
        :uid => user
      })
  end
end