class FeedWrapper
  include Enumerable

  def initialize(obj)
    @obj = obj
  end

  def [](key)
    if @obj.is_a?(Hash) || (@obj.is_a?(Array) && key.is_a?(Integer))
      self.class.new(@obj[key])
    else
      self.class.new(nil)
    end
  end

  def ==(obj)
    if obj.respond_to?(:unwrap)
      self.unwrap == obj.unwrap
    else
      self.unwrap == obj
    end
  end

  # This corrects for a quirk in XML-to-object parsing; usually an XML element
  # is converted to a hash with the element name as key and a hash as a value,
  # but sibling XML elements with the same name are converted to a hash with the
  # element name as key and an array of hashes as value. In cases where the number
  # of elements is unknown, this can ensure that single or blank results still come
  # wrapped in an array.
  def as_collection
    @obj.is_a?(Array) ? self : self.class.new(self.to_a)
  end

  def blank?
    @obj.blank?
  end

  def content(default='')
    if @obj.is_a? String
      self.to_text(default)
    else
      self['__content__'].to_text(default)
    end
  end

  def each
    if @obj.respond_to?(:each)
      @obj.each { |e| yield self.class.new(e) }
    end
  end

  def find_by(key, value)
    self.find { |e| e[key].unwrap == value } || self.class.new(nil)
  end

  def to_a
    if @obj.is_a?(Array)
      @obj
    elsif @obj.blank?
      []
    else
      [@obj]
    end
  end

  def to_date(default='')
    Date.parse(self.to_text).in_time_zone.to_datetime rescue default
  end

  def to_i(default=0)
    @obj.try(:to_i) || default
  end

  def to_text(default='')
    @obj.try(:to_s).try(:strip) || default
  end

  def to_time(default='')
    num = self.to_text.gsub(/^0/, '')
    if num.match(/\A[0-9]+\Z/) && num.length > 2
      num.insert(num.length - 2, ':')
    else
      default
    end
  end

  def unwrap
    @obj
  end
end
