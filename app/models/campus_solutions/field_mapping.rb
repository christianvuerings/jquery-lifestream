module CampusSolutions
  class FieldMapping

    def self.required(name, cs_name)
      {
        field_name: name,
        campus_solutions_name: cs_name,
        is_required: true
      }
    end

    def self.optional(name, cs_name)
      {
        field_name: name,
        campus_solutions_name: cs_name,
        is_required: false
      }
    end

    def self.to_hash(mappings = [])
      result = {}
      mappings.map { |field|
        result[field[:field_name]] = field
      }
      result
    end

  end
end
