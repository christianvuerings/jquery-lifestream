module Canvas
  class PublicAuthorizer
    extend Cache::Cacheable

    def initialize(canvas_user_id)
      @canvas_user_id = canvas_user_id
    end

    def can_create_site?
      self.class.fetch_from_cache @canvas_user_id do
        authorization = false
        campus_uid = Canvas::UserProfile.new(:canvas_user_id => @canvas_user_id).login_id
        if campus_uid
          user = AuthenticationState.new('user_id' => campus_uid)
          policy = user.policy
          # if you cannot create a project site (i.e. you are not affiliated as a staff or faculty member),
          # then you surely will not have official sections available to create a course site
          authorization = policy.can_create_canvas_project_site?
        end
        authorization
      end
    end

  end
end
