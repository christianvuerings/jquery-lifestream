class TermCodes

  def self.codes
    @codes ||= {
      :B => "Spring",
      :C => "Summer",
      :D => "Fall"
    }
  end

  def self.names
    @names ||= self.init_names
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

  def self.to_code(name)
    name = self.names[name.downcase]
    unless name
      raise ArgumentError, "No such term code: #{name}"
    end
    name
  end

  private

  def self.init_names
    names = {}
    self.codes.keys.each do |key|
      name = self.codes[key]
      names[name.downcase] = key.to_s
    end
    names
  end

end
