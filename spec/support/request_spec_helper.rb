module RequestSpecHelper

  def login_with_cas(user)
    currentAuth = OmniAuth.config.mock_auth[:cas]
    unless currentAuth.is_a?(Symbol)
      OmniAuth.config.mock_auth[:cas] = OmniAuth::AuthHash.new(
        {
          :provider => 'cas',
          :uid => user
        })
    end
    get login_path
  end

end