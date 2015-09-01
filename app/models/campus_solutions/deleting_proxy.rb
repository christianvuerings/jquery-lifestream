module CampusSolutions
  class DeletingProxy < PostingProxy

    def mock_request
      super.merge(method: :delete)
    end

    def construct_cs_post(filtered_params)
      cs_post = default_post_params
      filtered_params.each do |calcentral_param_name, value|
        mapping = self.class.field_mappings[calcentral_param_name]
        next if mapping.blank?
        cs_param_name = mapping[:campus_solutions_name]
        cs_post[cs_param_name] = value
      end
      {
        query: cs_post
      }
    end

    def request_options
      updateable_params = filter_updateable_params params
      params = construct_cs_post updateable_params
      {method: :delete}.merge(params)
    end

  end
end
