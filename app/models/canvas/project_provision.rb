module Canvas
  class ProjectProvision
    include ClassLogger, SafeJsonParser
    extend Cache::Cacheable

    def initialize(uid)
      @uid = uid
    end

    def unique_sis_project_id
      15.times do
        sis_course_id = 'PROJ:' + SecureRandom.hex(8)
        canvas_course_id = Canvas::SisCourse.new(:user_id => @uid, :sis_course_id => sis_course_id).course
        return sis_course_id unless canvas_course_id
      end
      raise RuntimeError, 'Unable to find unique SIS Course ID for Project Site'
    end

    def create_project(project_name)
      project_account_id = Settings.canvas_proxy.projects_account_id
      term_id = Settings.canvas_proxy.projects_term_id
      worker = Canvas::Course.new(:user_id => @uid)
      response = worker.create(project_account_id, project_name, project_name, term_id, unique_sis_project_id)
      if response.status >= 400
        raise Errors::ProxyError.new("Project Site creation request failed: #{response.status} #{response.body};")
      end
      Rails.logger.debug "#{self.class.name}: Remote server status #{response.status}, Body = #{response.body}"
      course_details = safe_json(response.body)
      enrollment = Canvas::CourseAddUser.add_user_to_course(@uid, 'TeacherEnrollment', course_details['id'], :role_id => Settings.canvas_proxy.projects_owner_role_id)
      return {:projectSiteId => course_details['id'], :projectSiteUrl => Settings.canvas_proxy.url_root + '/courses/' + course_details['id'].to_s, :enrollment_id => enrollment['id']}
    end
  end
end
