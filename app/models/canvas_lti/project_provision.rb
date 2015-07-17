module CanvasLti
  class ProjectProvision
    include ClassLogger, SafeJsonParser
    extend Cache::Cacheable

    def initialize(uid)
      @uid = uid
    end

    def unique_sis_project_id
      15.times do
        sis_course_id = 'PROJ:' + SecureRandom.hex(8)
        existing_course_for_id = Canvas::SisCourse.new(user_id: @uid, sis_course_id: sis_course_id).course
        return sis_course_id unless existing_course_for_id[:statusCode] == 200
      end
      raise RuntimeError, 'Unable to find unique SIS Course ID for Project Site'
    end

    def create_project(project_name)
      project_account_id = Settings.canvas_proxy.projects_account_id
      term_id = Settings.canvas_proxy.projects_term_id
      worker = Canvas::Course.new(user_id: @uid)
      response = worker.create(project_account_id, project_name, project_name, term_id, unique_sis_project_id)
      if (course_details = response[:body])
        enrollment = CanvasLti::CourseAddUser.add_user_to_course(@uid, 'TeacherEnrollment', course_details['id'], role_id: Settings.canvas_proxy.projects_owner_role_id)
        {
          projectSiteId: course_details['id'],
          projectSiteUrl: "#{Settings.canvas_proxy.url_root}/courses/#{course_details['id']}",
          enrollment_id: enrollment['id']
        }
      else
        raise Errors::ProxyError.new("Project Site creation request failed: #{response[:statusCode]} #{response[:body]}")
      end
    end
  end
end
