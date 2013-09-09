class TermCodes

  def self.codes
    @codes ||= {
      :B => "Spring",
      :C => "Summer",
      :D => "Fall"
    }
  end

  def self.to_english(term_yr, term_cd)
    term = self.codes[term_cd.to_sym]
    unless term
      raise ArgumentError, "No such term code: #{term_cd}"
    end
    "#{term} #{term_yr}"
  end

  def self.to_slug(term_yr, term_cd)
    term = self.codes[term_cd.to_sym]
    unless term
      raise ArgumentError, "No such term code: #{term_cd}"
    end
    "#{term.downcase}-#{term_yr}"
  end

end
