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
    if (model = valid_model(params[:instructor_id]))
      # Since we expect the CCNs to have been provided by our own code rather than a human being,
      # we don't worry so much about invalid numbers.
      ccns = params[:ccns]
      results = model.create_course_site(params[:term_slug], ccns)
      render json: results.to_json
    else
      render nothing: true, status: 401
    end
  end

  def valid_model(as_instructor_id)
    user_id = session[:user_id]
    if user_id.blank?
      logger.warn("Bad request made to Canvas Course Provision: session user = #{user_id}")
      nil
    else
      CanvasCourseProvision.new(user_id, as_instructor: as_instructor_id)
    end
  end

end
