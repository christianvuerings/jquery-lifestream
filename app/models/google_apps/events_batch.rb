module GoogleApps
  class EventsBatch < Events

    include ClassLogger

    def batch_request(request_params_array=[])
      request_params_array.each do |request_params|
        page_params = setup_page_params(request_params)
        logger.debug "page params = #{page_params.inspect}"
      end
    end
  end
end
