class CampusRostersController < RostersController
  include ClassLogger

  # GET /api/academics/rosters/campus/:campus_course_id
  def get_feed
    if (model = valid_model(params[:campus_course_id], "Campus"))
      if (feed = model.get_feed)
        render :json => feed.to_json
      else
        render :nothing => true, :status => 401
      end
    else
      render :nothing => true, :status => 401
    end
  end

end
