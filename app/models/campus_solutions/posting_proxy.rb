module CampusSolutions
  class PostingProxy < Proxy

    attr_reader :params

    def initialize(settings, options = {})
      super(settings, options)
      @params = options[:params]
      initialize_mocks if @fake
    end

    def self.expires_in
      1.seconds
    end

    def mock_request
      super.merge(method: :post)
    end

    def request_options
      updateable_params = filter_updateable_params params
      cs_post = construct_cs_post updateable_params
      logger.debug "POST Body: #{cs_post}"
      super.merge(method: :post, body: cs_post)
    end

    def default_post_params
      {}
    end

    # lets us restrict updated params to what's on the whitelist of field mappings.
    def filter_updateable_params(params)
      return {} unless params
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
      cs_post = default_post_params
      filtered_params.each do |calcentral_param_name, value|
        mapping = self.class.field_mappings[calcentral_param_name]
        next if mapping.blank?
        cs_param_name = mapping[:campus_solutions_name]
        cs_post[cs_param_name] = value
      end
      # CampusSolutions will barf if it encounters whitespace or newlines
      cs_post.to_xml(root: root_xml_node, dasherize: false, indent: 0)
    end

  end
end
