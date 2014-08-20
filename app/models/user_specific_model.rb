class UserSpecificModel < AbstractModel
  attr_reader :authentication_state

  def self.from_session(session_state)
    self.new(session_state[:user_id], {
      original_user_id: session_state[:original_user_id],
      lti_authenticated_only: session_state[:lti_authenticated_only]
    })
  end

  def initialize(uid, options={})
    super(uid, options)
    @uid = uid
    @authentication_state = AuthenticationState.new(@options.merge(user_id: @uid))
  end

  def directly_authenticated?
    @authentication_state.directly_authenticated?
  end

end
