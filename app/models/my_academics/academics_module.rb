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

end
