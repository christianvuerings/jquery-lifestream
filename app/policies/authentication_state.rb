class AuthenticationState
  attr_reader :user_id, :original_user_id, :lti_authenticated_only

  LTI_AUTHENTICATED_ONLY = 'Authenticated through LTI'

  def initialize(session_state)
    @user_id = session_state[:user_id]
    @original_user_id = session_state[:original_user_id]
    @lti_authenticated_only = session_state[:lti_authenticated_only]
  end

  def directly_authenticated?
    user_id && !lti_authenticated_only &&
      (original_user_id.blank? ||
        (user_id == original_user_id))
  end

  def original_user_auth
    @original_user_auth ||= User::Auth.get(original_user_id)
  end

  def policy
    @policy ||= AuthenticationStatePolicy.new(self, self)
  end

  def real_user_auth
    if original_user_id && user_id
      return original_user_auth
    elsif lti_authenticated_only
      # Public permissions only.
      return User::Auth.get(nil)
    else
      return user_auth
    end
  end

  def real_user_id
    if user_id.present?
      if original_user_id.present?
        return original_user_id
      elsif lti_authenticated_only
        return LTI_AUTHENTICATED_ONLY
      else
        return user_id
      end
    else
      return nil
    end
  end

  # For better exception messages.
  def to_s
    "#{super.to_s} user_id=#{@user_id}, original_user_id=#{@original_user_id}, lti_authenticated_only=#{@lti_authenticated_only}"
  end

  def user_auth
    @user_auth ||= User::Auth.get(user_id)
  end

  def viewing_as?
    original_user_id && user_id && (original_user_id != user_id)
  end

end
