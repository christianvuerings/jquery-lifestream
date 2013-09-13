module MyAcademics::AcademicsModule
  extend self

  def initialize(uid)
    @uid = uid
  end

  def to_text(element)
    if element.blank?
      return ""
    else
      return element.text.strip
    end
  end

  def to_time(element)
    str = to_text(element)
    num = str.gsub(/^0/, "")
    formatted = num.insert(num.length - 2, ":")
    formatted
  end

  def make_slug(text)
    if text.blank?
      ""
    else
      text.downcase.gsub(/[^a-z0-9]+/, '-').chomp('-')
    end
  end

  # Link campus courses to internal class pages for the current semester.
  def class_to_url(term_cd, term_year, department, catalog_id, role)
    teaching_str = (role == 'Instructor') ? 'teaching-' : ''
    "/academics/#{teaching_str}semester/#{TermCodes.to_slug(term_year, term_cd)}/class/#{course_to_slug(department, catalog_id)}"
  end

  def course_to_slug(department, catalog_id)
    "#{department.downcase.gsub(/[^a-z0-9]+/, '_')}-#{catalog_id.downcase.gsub(/[^a-z0-9]+/, '_')}"
  end

end
