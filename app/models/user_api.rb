class UserApi < MyMergedModel
  include ActiveRecordHelper

  def initialize(uid)
    super(uid)
  end

  def init
    use_pooled_connection{
      @calcentral_user_data ||= UserData.where(:uid => @uid).first
    }
    @campus_attributes ||= CampusData.get_person_attributes(@uid) || {}
    @default_name ||= @campus_attributes['person_name']
    @first_login_at ||= @calcentral_user_data ? @calcentral_user_data.first_login_at : nil
    @first_name ||= @campus_attributes['first_name'] || ""
    @last_name ||= @campus_attributes['last_name'] || ""
    @override_name ||= @calcentral_user_data ? @calcentral_user_data.preferred_name : nil
  end

  def preferred_name
    @override_name || @default_name || ""
  end

  def preferred_name=(val)
    if val.blank?
      val = nil
    else
      val.strip!
    end
    @override_name = val
  end

  def self.delete(uid)
    logger.debug "#{self.class.name} removing user #{uid} from UserData"
    user = nil
    use_pooled_connection {
      user = UserData.where(:uid => uid).first
      if !user.blank?
        user.delete
      end
    }
    if !user.blank?
      # The nice way to do this is to also revoke their tokens by sending revoke request to the remote services
      use_pooled_connection {
        Oauth2Data.destroy_all(:uid => uid)
        Notification.destroy_all(:uid => uid)
      }
    end

    Calcentral::USER_CACHE_EXPIRATION.notify uid
  end

  def save
    use_pooled_connection {
      # Avoid race condition problems, UserData could have been modified or already instantiated
      # by another thread.
      @calcentral_user_data = UserData.where(uid: @uid).first_or_create do |record|
        record.preferred_name = @override_name
        record.first_login_at = @first_login_at
      end
      if @calcentral_user_data.preferred_name != @override_name
        @calcentral_user_data.update_attribute(:preferred_name, @override_name)
      end
    }
    Calcentral::USER_CACHE_EXPIRATION.notify @uid
  end

  def update_attributes(attributes)
    init
    if attributes.has_key?(:preferred_name)
      self.preferred_name = attributes[:preferred_name]
    end
    save
  end

  def record_first_login
    init
    @first_login_at = DateTime.now
    save
  end

  def get_feed_internal
    google_mail = Oauth2Data.get_google_email(@uid)
    canvas_mail = Oauth2Data.get_canvas_email(@uid)
    {
      :is_admin => UserAuth.is_superuser?(@uid),
      :first_login_at => @first_login_at,
      :first_name => @first_name,
      :full_name => @first_name + ' ' + @last_name,
      :has_canvas_account => CanvasProxy.has_account?(@uid),
      :has_google_access_token => GoogleProxy.access_granted?(@uid),
      :google_email => google_mail,
      :canvas_email => canvas_mail,
      :last_name => @last_name,
      :preferred_name => self.preferred_name,
      :roles => @campus_attributes[:roles],
      :student_info => {
          :california_residency => @campus_attributes[:california_residency],
          :education_level => @campus_attributes[:education_level],
          :reg_status => @campus_attributes[:reg_status],
          :reg_block => @campus_attributes[:reg_block],
          :units_enrolled => @campus_attributes[:units_enrolled]
      },
      :uid => @uid
    }
  end

end
