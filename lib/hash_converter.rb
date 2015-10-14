module HashConverter

  # Camel-case and symbolize keys across a tree or array of hashes. Values are left unchanged.
  def self.camelize(value)
    case value
      when Array
        value.map { |v| HashConverter.camelize(v) }
      when Hash
        Hash[value.map { |k, v| [k.to_s.camelize(:lower).to_sym, HashConverter.camelize(v)] }]
      else
        value
    end
  end

  def self.downcase_and_camelize(value)
    case value
      when Array
        value.map { |v| HashConverter.downcase_and_camelize(v) }
      when Hash
        Hash[value.map { |k, v| [k.to_s.downcase.camelize(:lower).to_sym, HashConverter.downcase_and_camelize(v)] }]
      else
        value
    end
  end

  def self.symbolize(value)
    case value
      when Array
        value.map { |v| HashConverter.symbolize(v) }
      when Hash
        Hash[value.map { |k, v| [k.to_s.to_sym, HashConverter.symbolize(v)] }]
      else
        value
    end
  end

end
