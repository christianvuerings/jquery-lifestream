module HubEdos
  class Student < Proxy

    include Cache::UserCacheExpiry

    SENSITIVE_KEYS = ['addresses', 'names', 'phones', 'emails', 'emergencyContacts']

    def initialize(options = {})
      super(Settings.hub_edos_proxy, options)
    end

    def url
      "#{@settings.base_url}/#{@campus_solutions_id}/all"
    end

    def xml_filename
      'student.xml'
    end

    def build_feed(response)
      transformed_response = redact_sensitive_keys(transform_address_keys(convert_plurals(parse_response(response))))
      {
        'student' => transformed_response
      }
    end

    def convert_plurals(response)
      converted = response['StudentResponse']['students']['student']
      %w(identifier name affiliation address phone email url ethnicity language foreignCountry emergencyContact).each do |field|
        convert_plural(converted, field)
      end
      converted
    end

    def convert_plural(hash, singular_key)
      plural_key = singular_key.pluralize
      if hash[plural_key].present? && hash[plural_key][singular_key].present?
        if hash[plural_key][singular_key].is_a?(Array)
          hash[plural_key] = hash[plural_key][singular_key]
        else
          hash[plural_key] = [hash[plural_key][singular_key]]
        end
      end
    end

    def transform_address_keys(student)
      # this should really be done in the Integration Hub, but they won that argument due to time constraints.
      student['addresses'].each do |address|
        address['state'] = address.delete('stateCode')
        address['postal'] = address.delete('postalCode')
        address['country'] = address.delete('countryCode')
      end
      student
    end

    def redact_sensitive_keys(student)
      # more stuff the Integration Hub should be doing, but the team doesn't have time for.
      SENSITIVE_KEYS.each do |key|
        if student[key].present?
          student[key].delete_if { |k| k['uiControl'].present? && k['uiControl']['code'] == 'N' }
        end
      end
      student
    end

  end
end
