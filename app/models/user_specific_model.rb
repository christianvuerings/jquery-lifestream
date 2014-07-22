class UserSpecificModel < AbstractModel

  def self.from_session(session_state)
    self.new(session_state[:user_id], {
      original_user_id: session_state[:original_user_id],
      lti_authenticated_only: session_state[:lti_authenticated_only]
    })
  end

  def initialize(uid, options={})
    super(uid, options)
    @uid = uid
  end

  def indirectly_authenticated?
    self.class.session_indirectly_authenticated?(@options.merge(user_id: @uid))
  end

  def self.session_indirectly_authenticated?(session_state)
    return true if session_state[:lti_authenticated_only]
    uid = session_state[:user_id]
    original_uid = session_state[:original_user_id]
    current_user = User::Auth.get(uid)
    original_uid && uid != original_uid && !current_user.is_test_user
  end

end
