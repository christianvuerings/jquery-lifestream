module HubEdos
  class Contacts < Student

    include Cache::UserCacheExpiry

    def initialize(options = {})
      super(options)
    end

    def url
      "#{@settings.base_url}/#{@campus_solutions_id}/contacts"
    end

    def json_filename
      'student_contacts.json'
    end

    def include_fields
      %w(identifiers names addresses phones emails urls emergencyContacts confidential)
    end

  end
end
