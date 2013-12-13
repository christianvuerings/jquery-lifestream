class CanvasRostersController < ApplicationController
  include ClassLogger

  # GET /api/academics/rosters/canvas/:canvas_course_id
  def get_feed
    if (model = valid_model(params[:canvas_course_id]))
      if (feed = model.get_feed)
        render :json => feed.to_json
      else
        render :nothing => true, :status => 401
      end
    else
      render :nothing => true, :status => 401
    end
  end

  # GET /canvas/:canvas_course_id/photo/:person_id
  def photo
    if (model = valid_model(params[:canvas_course_id]))
      canvas_user_id = Integer(params[:person_id], 10)
      photo = model.photo_data_or_file(canvas_user_id)
      if (photo.nil?)
        render :nothing => true, :status => 401
      elsif (data = photo[:data])
        send_data(
            data,
            type: 'image/jpeg',
            disposition: 'inline'
        )
      else
        send_file(
            photo[:filename],
            type: 'image/jpeg',
            disposition: 'inline'
        )
      end
    else
      render :nothing => true, :status => 401
    end
  end

  def valid_model(canvas_course_id)
    user_id = session[:user_id]
    if user_id.blank? || canvas_course_id.blank?
      logger.warn("Bad request made to Canvas Rosters: session user = #{user_id}, requested Canvas course #{canvas_course_id}")
      nil
    else
      if canvas_course_id == 'embedded'
        canvas_course_id = session[:canvas_lti_params] && session[:canvas_lti_params]['custom_canvas_course_id']
        if canvas_course_id.blank?
          logger.warn("Bad embedded request made to Canvas Rosters: session user = #{user_id}")
          return nil
        end
      end
      canvas_course_id = Integer(canvas_course_id, 10)
      CanvasRosters.new(user_id, canvas_course_id: canvas_course_id)
    end
  end

end
