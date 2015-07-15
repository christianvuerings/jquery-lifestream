module Canvas
  class Admins < Proxy

    def initialize(options = {})
      super(options)
      account_id = options[:account_id] || settings.account_id
      raise ArgumentError, 'Account ID option must be a String or Fixnum' unless [String,Fixnum].include? account_id.class
      @account_id = account_id
    end

    def admin_user?(uid)
      admins = self.class.fetch_from_cache(@account_id) { paged_get request_path }
      admins[:body].present? && admins[:body].index {|acct| acct['user']['sis_login_id'] == uid.to_s}.present?
    end

    private

    def request_path
      "accounts/#{@account_id}/admins"
    end

    def mock_json
      if @account_id == settings.account_id
        read_file('fixtures', 'json', 'canvas_admins.json')
      else
        read_file('fixtures', 'json', "canvas_admins_#{@account_id}.json")
      end
    end
  end
end
