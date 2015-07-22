module CampusSolutions

  class DirectProxy < Proxy

    def initialize(options = {})
      super(Settings.campus_solutions_proxy, options)
      initialize_mocks if @fake
    end

    def request_options
      {
        basic_auth: {
          username: @settings.username,
          password: @settings.password
        }
      }
    end

    # lets us restrict updated params to what's on the whitelist of field mappings.
    def filter_updateable_params(params)
      updateable = {}
      known_fields = self.class.field_mappings
      params.each do |calcentral_param_name, value|
        if known_fields[calcentral_param_name.to_sym].present?
          updateable[calcentral_param_name.to_sym] = value
        end
      end
      updateable
    end

    def construct_cs_post(filtered_params)
      cs_post = {}
      filtered_params.each do |calcentral_param_name, value|
        mapping = self.class.field_mappings[calcentral_param_name]
        next if mapping.blank?
        cs_param_name = mapping[:campus_solutions_name]
        cs_post[cs_param_name] = value
      end
      cs_post
    end

  end
end
