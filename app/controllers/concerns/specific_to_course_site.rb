module SpecificToCourseSite
  def canvas_course_id
    begin
      if (id = params[:canvas_course_id])
        id = session[:canvas_course_id] if id == 'embedded'
        id = Integer(id, 10)
      end
      id
    rescue ArgumentError
      nil
    end
  end
end
