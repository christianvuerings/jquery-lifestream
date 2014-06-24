module Berkeley
  # Represents campus course for Pundit authorization performed by Berkeley::CoursePolicy
  class Course

    attr_accessor :course_id

    def initialize(options = {})
      @course_id = options[:course_id]
    end
  end
end
