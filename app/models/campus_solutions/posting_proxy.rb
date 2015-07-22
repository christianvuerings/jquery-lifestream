module CampusSolutions
  class PostingProxy < DirectProxy

    attr_accessor :params

    def request_options
      updateable_params = filter_updateable_params params
      cs_post = construct_cs_post updateable_params
      options = super.merge(method: :post, query: cs_post)
      logger.debug "All POST Options: #{options.inspect}"
      options
    end

  end
end
