class UserApi
  include ActiveModel::Serialization
  attr_accessor :uid

  def initialize(uid)
    self.uid = uid
    @calcentral_user_data = UserData.where(:uid => self.uid).first
    @campus_attributes = CampusData.get_person_attributes(self.uid) || {}
    @default_name = @campus_attributes['person_name']
    @override_name = @calcentral_user_data ? @calcentral_user_data.preferred_name : nil
  end

  def preferred_name
    @override_name || @default_name
  end
  def preferred_name=(val)
    if val.blank?
      val = nil
    else
      val.strip!
    end
    @override_name = val
  end

  def save
    if !@calcentral_user_data
      @calcentral_user_data = UserData.create(uid: self.uid, preferred_name: @override_name)
    else
      stored_override = @calcentral_user_data.preferred_name
      if stored_override != @override_name
        @calcentral_user_data.update_attributes(preferred_name: @override_name)
      end
    end
    Calcentral::USER_CACHE_EXPIRATION.notify self.uid
  end

  def update_attributes(attributes)
    if attributes.has_key?(:preferred_name)
      self.preferred_name = attributes[:preferred_name]
    end
    save
  end

  def self.get_user_data(uid)
    Rails.cache.fetch(UserApi.cache_key(uid)) do
      user = UserApi.new(uid)
      {
          :uid => user.uid,
          :preferred_name => user.preferred_name || "",
          :widget_data => {},
          :has_canvas_access_token => CanvasProxy.access_granted?(user.uid),
          :has_google_access_token => GoogleProxy.access_granted?(user.uid)
      }
    end
  end

  def self.cache_key(uid)
    "user/#{uid}/UserApi/get_user_data"
  end

  def self.expire(uid)
    Rails.cache.delete(self.cache_key(uid), :force => true)
  end

end
