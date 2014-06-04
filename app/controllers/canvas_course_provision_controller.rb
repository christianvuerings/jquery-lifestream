class CanvasCourseProvisionController < ApplicationController
  include ClassLogger

  # GET /api/academics/canvas/course_provision.json
  # GET /api/academics/canvas/course_provision_as/:instructor_id.json
  def get_feed
    if (model = valid_model(options_from_params))
      if (feed = model.get_feed)
        render json: feed.to_json
      else
        render nothing: true, status: 401
      end
    else
      render nothing: true, status: 401
    end
  rescue SecurityError => error
    render nothing: true, status: 401
  rescue ArgumentError => error
    render nothing: true, status: 400
  end

  # POST /api/academics/canvas/course_provision/create.json
  def create_course_site
    model = valid_model(options_from_params)
    # Since we expect the CCNs to have been provided by our own code rather than a human being,
    # we don't worry so much about invalid numbers.
    job_id = model.create_course_site(params[:siteName], params[:siteAbbreviation], params[:termSlug], params[:ccns])
    render json: { job_request_status: "Success", job_id: job_id}.to_json
  rescue SecurityError => error
    render nothing: true, status: 401
  rescue StandardError => error
    render json: { job_request_status: 'Error', job_id: nil, error: error.message }.to_json
  end

  # GET /api/academics/canvas/course_provision/status.json
  def job_status
    course_provision_job = Canvas::ProvideCourseSite.find(params[:job_id])
    render json: course_provision_job.to_json and return if course_provision_job.class == Canvas::ProvideCourseSite
    render json: { job_id: params[:job_id], status: "Error", error: "Unable to find course provisioning job" }.to_json
  end

  def valid_model(options)
    user_id = session[:user_id]
    if user_id.blank?
      logger.warn("Bad request made to Canvas Course Provision: session user = #{user_id}")
      raise SecurityError, "Bad request made to Canvas Course Provision: No session user"
    end
    if options[:admin_acting_as] && (options[:admin_by_ccns] || options[:admin_term_slug])
      logger.warn("Conflicting request parameters sent to Canvas Course Provision: session user = #{user_id}, options = #{options}")
      raise ArgumentError, "Conflicting request parameters sent to Canvas Course Provision"
    end
    Canvas::CourseProvision.new(user_id, options)
  end

  def options_from_params
    params.select {|k, v| [
      'admin_acting_as',
      'admin_by_ccns',
      'admin_term_slug'
    ].include?(k)}.symbolize_keys
  end

end
