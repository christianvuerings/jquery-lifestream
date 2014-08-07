module Canvas
  class Logins < Proxy
    include ClassLogger

    # Get the account's Logins and find the appropriate one to change.
    #    GET /api/v1/users/sis_login_id:anldapuid/logins
    #   [{"account_id":1,"id":1040,"sis_user_id":"old_sis_id","unique_id":"anldapuid","user_id":1041}]
    # or
    #   [{"account_id":90242,"id":2963066,"sis_user_id":"211159","unique_id":"211159","user_id":3057506},
    #    {"account_id":90242,"id":4592428,"sis_user_id":null,"unique_id":"raydavis-testlogin","user_id":3057506}]

    def user_logins(canvas_user_id)
      request_uncached("users/#{canvas_user_id}/logins", '_user_logins')
    end

    # Change the sis_user_id of that Login record to match the LDAP-or-student-ID scheme.
    #   PUT /api/v1/accounts/1/logins/1040 -F 'login[sis_user_id]'=new_sis_id
    #   {"account_id":1,"id":1040,"sis_user_id":"new_sis_id","unique_id":"anldapuid","user_id":1041}
    #
    # Note: The 'Password setting by admins' option in Account Settings must be enabled for this to work.
    # This setting cannot be set by an Account Admin, but must be set by a Site Admin (Instructure staff)

    def change_sis_user_id(login_id, new_sis_user_id)
      url = "accounts/#{settings.account_id}/logins/#{login_id}?login[sis_user_id]=#{new_sis_user_id}"
      request_uncached(url, '_put_login_sis_user_id', {
        method: :put
      })
    end

  end
end
