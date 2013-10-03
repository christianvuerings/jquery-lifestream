class CanvasAdminsProxy < CanvasProxy

  def admins_list
    self.class.fetch_from_cache do
      all_admins = []
      params = "per_page=30"
      while params do
        response = request_uncached(
            "accounts/#{settings.account_id}/admins?#{params}",
            "_admins"
        )
        break unless response && response.status == 200
        admins_list = JSON.parse(response.body)
        all_admins.concat(admins_list)
        params = next_page_params(response)
      end
      all_admins
    end
  end

  def admin_user?(uid)
    list = admins_list
    list.index {|acct| acct['user']['sis_login_id'] == uid.to_s}
  end

end