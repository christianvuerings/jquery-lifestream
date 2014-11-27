module Canvas
  class Admins < Proxy

    include SafeJsonParser

    def initialize(options = {})
      super(options)
      default_options = {:account_id => settings.account_id}
      options.reverse_merge!(default_options)
      raise ArgumentError, "Account ID option must be a String or Fixnum" unless [String,Fixnum].include?(options[:account_id].class)
      @account_id = options[:account_id].to_s
    end

    def admin_user?(uid)
      admins = self.class.fetch_from_cache(@account_id) { request_admins_list(@account_id) }
      admins.index {|acct| acct['user']['sis_login_id'] == uid.to_s} ? true : false
    end

    private

    def request_admins_list(account_id)
      all_admins = []
      params = "per_page=100"
      account_id ||= settings.account_id
      while params do
        response = request_uncached(
          "accounts/#{account_id}/admins?#{params}",
          "_admins"
        )
        break unless (response && response.status == 200 && admins_list = safe_json(response.body))
        all_admins.concat(admins_list)
        params = next_page_params(response)
      end
      all_admins
    end

  end
end
