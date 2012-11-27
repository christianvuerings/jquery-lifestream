class Oauth2Data < ActiveRecord::Base
  attr_accessible :uid, :app_id, :access_token, :expiration_time, :refresh_token
  serialize :access_token
  serialize :refresh_token
  before_update :encrypt_tokens
  before_save :encrypt_tokens
  after_save :decrypt_tokens
  after_update :decrypt_tokens
  after_find :decrypt_tokens
  @@encryption_algorithm = Settings.oauth2.encryption || 'aes-256-cbc'

  def self.get_access_token(user_id, app_id)
    oauth2_data = Oauth2Data.where(uid: user_id, app_id: app_id).first
    oauth2_data && oauth2_data.access_token
  end

  def encrypt_tokens
    self.access_token = Oauth2Data.encrypt_with_iv(self.access_token, Settings.oauth2.key)
    if (self.refresh_token)
      self.refresh_token = Oauth2Data.encrypt_with_iv(self.refresh_token, Settings.oauth2.key)
    end
  end

  def decrypt_tokens
    self.access_token = Oauth2Data.decrypt_with_iv(self.access_token, Settings.oauth2.key)
    if (self.refresh_token)
      self.refresh_token = Oauth2Data.decrypt_with_iv(self.refresh_token, Settings.oauth2.key)
    end
  end

  def self.encrypt_with_iv(value, key)
    cipher = OpenSSL::Cipher::Cipher.new(@@encryption_algorithm)
    cipher.encrypt
    iv = cipher.random_iv
    cipher.key = key
    cipher.iv = iv
    encrypted = cipher.update(value) + cipher.final
    [Base64.encode64(encrypted), Base64.encode64(iv)]
  end

  def self.decrypt_with_iv(value_with_iv, key)
    cipher = OpenSSL::Cipher::Cipher.new(@@encryption_algorithm)
    cipher.decrypt
    cipher.key = key
    cipher.iv = Base64.decode64(value_with_iv[1])
    decrypted = cipher.update(Base64.decode64(value_with_iv[0])) + cipher.final
    decrypted.to_s
  end

end
