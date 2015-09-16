module HubEdos
  class UserAttributes < Proxy

    def initialize(options = {})
      super(Settings.hub_edos_proxy, options)
      initialize_mocks if @fake
    end

    def url
      ''
    end

    def json_filename
      'user_attributes.json'
    end

    def get_internal
      edo_feed = Student.new(user_id: @uid).get
      result = {}
      if (edo = edo_feed[:feed])
        extract_ids(edo, result)
        extract_names(edo, result)
        result[:statusCode] = 200
      else
        logger.error "Could not get Student EDO data for uid #{@uid}"
      end
      result
    end

    def extract_ids(edo, result)
      edo['student']['identifiers'].each do |id|
        if id['type'] == 'CalNet UID'
          result[:ldap_uid] = id['id']
        elsif id['type'] == 'Student ID'
          result[:student_id] = id['id']
        end
      end
    end

    def extract_names(edo, result)
      edo['student']['names'].each do |name|
        # use preferred name
        if name['type']['code'] == 'PRF'
          result[:first_name] = name['givenName']
          result[:last_name] = name['familyName']
          result[:person_name] = name['formattedName']
          break
        end
      end
    end

  end
end
