module MyAcademics::AcademicsModule

  def initialize(uid)
    @uid = uid
  end

  def to_text(element)
    if element.nil? || element.empty?
      return ""
    else
      return element.text.strip
    end
  end

end
