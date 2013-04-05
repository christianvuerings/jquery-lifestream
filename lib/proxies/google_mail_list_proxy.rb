class GoogleMailListProxy < BaseProxy

  class << self
    def atom_feed
      @atom_feed ||= 'https://mail.google.com/mail/feed/atom/'
    end
  end


  def initialize(options = {})
    super(Settings.google_proxy, options)

    if @fake
      @authorization = GoogleProxyClient.new_fake_auth
    elsif options[:user_id]
      token_settings = Oauth2Data.get(@uid, GoogleProxy::APP_ID)
      @authorization = GoogleProxyClient.new_client_auth token_settings
    else
      auth_related_entries = [:access_token, :refresh_token, :expiration_time]
      token_settings = options.select{ |k,v| auth_related_entries.include? k}.stringify_keys!
      @authorization = GoogleProxyClient.new_client_auth token_settings
    end

    @fake_options = options[:fake_options] || {}
  end

  def mail_unread
    FakeableProxy.wrap_request("#{GoogleProxy::APP_ID}_mail", @fake, @fake_options) {
      begin
        client = GoogleProxyClient.client.dup
        client.authorization = @authorization
        client.execute(
          :http_method => :get,
          :uri => self.class.atom_feed,
          :authenticated => true
        )
      rescue Exception => e
        Rails.logger.fatal "#{self.class.name}: #{e.to_s} - Unable to send request transaction"
        nil
      end
    }
  end

end
