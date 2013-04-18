module MyAcademics::AcademicsModule

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

  def make_slug(text)
    if text.blank?
      ""
    else
      text.downcase.gsub(/[^a-z0-9]+/, '-').chomp('-')
    end
  end

end
