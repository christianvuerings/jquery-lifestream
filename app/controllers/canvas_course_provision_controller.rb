class CanvasCourseProvisionController < ApplicationController
  include ClassLogger

  def get_feed
    if (model = valid_model(params[:instructor_id]))
      if (feed = model.get_feed)
        render json: feed.to_json
      else
        render nothing: true, status: 401
      end
    else
      render nothing: true, status: 401
    end
  end

  def create_course_site
    model = valid_model(params[:instructor_id])
    # Since we expect the CCNs to have been provided by our own code rather than a human being,
    # we don't worry so much about invalid numbers.
    results = model.create_course_site(params[:term_slug], params[:ccns])
    render json: results.to_json
  rescue SecurityError => error
    render nothing: true, status: 401
  rescue StandardError => error
    render json: { created_status: 'ERROR', created_message: error.message }.to_json
  end

  def valid_model(as_instructor_id)
    user_id = session[:user_id]
    if user_id.blank?
      logger.warn("Bad request made to Canvas Course Provision: session user = #{user_id}")
      raise SecurityError, "Bad request made to Canvas Course Provision: No session user"
    end
    CanvasCourseProvision.new(user_id, as_instructor: as_instructor_id)
  end

end
