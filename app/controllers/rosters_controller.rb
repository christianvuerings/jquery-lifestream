class RostersController < ApplicationController
  include ClassLogger

  # GET /canvas/:canvas_course_id/photo/:person_id
  def photo
    if !params[:canvas_course_id].nil?
      course_id = params[:canvas_course_id]
      request_type = "Canvas"
    elsif !params[:campus_course_id].nil?
      course_id = params[:campus_course_id]
      request_type = "Campus"
    end

    if (model = valid_model(course_id, request_type))
      course_user_id = Integer(params[:person_id], 10)
      photo = model.photo_data_or_file(course_user_id)
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

  def valid_model(course_id, request_type)
    user_id = session[:user_id]
    if user_id.blank? || course_id.blank?
      logger.warn("Bad request made to #{request_type} Rosters: session user = #{user_id}, requested #{request_type} course #{course_id}")
      nil
    else
      if request_type == 'Canvas'
        if course_id == 'embedded'
          course_id = session[:canvas_course_id]
          if course_id.blank?
            logger.warn("Bad embedded request made to Canvas Rosters: session user = #{user_id}")
            return nil
          end
        end
        course_id = Integer(course_id, 10)
        Canvas::CanvasRosters.new(user_id, course_id: course_id)
      else
        if request_type == 'Campus'
          Rosters::Campus.new(user_id, course_id: course_id)
        end
      end
    end
  end

end
