class UserSpecificModel < AbstractModel

  def initialize(uid, options={})
    super(uid, options)
    @uid = uid
    if options
      @original_uid = options[:original_user_id]
    end
  end

  def instance_key
    if is_acting_as_nonfake_user?
      Calcentral::PSEUDO_USER_PREFIX + @uid
    else
      @uid
    end
  end

  # chikoon: this method could be used by any model that inherits from UserSpecificModel
  # the problem is that many methods don't, and so this acting_as? method will
  # most probably need to be removed
  def acting_as?
    (@original_uid && (@original_uid != @uid))
  end

  def is_acting_as_nonfake_user?
    current_user = User::Auth.get(@uid)
    @original_uid && @uid != @original_uid && !current_user.is_test_user
  end

  def expire_cache
    super
    self.class.expire(Calcentral::PSEUDO_USER_PREFIX + @uid)
  end

end
