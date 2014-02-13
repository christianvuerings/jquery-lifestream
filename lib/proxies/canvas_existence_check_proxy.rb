class CanvasExistenceCheckProxy < CanvasProxy

  def account_defined?(sis_account_id)
    response = request_uncached("accounts/sis_account_id:#{sis_account_id}", '_account')
    response.present?
  end

  def course_defined?(sis_course_id)
    response = request_uncached("courses/sis_course_id:#{sis_course_id}", '_course')
    response.present?
  end

  def section_defined?(sis_section_id)
    response = request_uncached("sections/sis_section_id:#{sis_section_id}", '_section')
    response.present?
  end

  def existence_check
    true
  end

end
