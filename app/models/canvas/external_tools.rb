module Canvas
  class ExternalTools < Proxy

    include SafeJsonParser

    # Unlike other Canvas proxies, this can make requests to multiple Canvas servers.
    def initialize(options = {})
      super(options)
      if (canvas_url_root = options[:url_root])
        @settings.url_root = canvas_url_root
      end
    end

    # Do not cache, since this is used to change external tools configurations on multiple Canvas servers.
    def external_tools_list
      all_tools = []
      params = 'per_page=100'
      while params do
        response = request_uncached(
          "accounts/#{settings.account_id}/external_tools?#{params}",
          "_external_tools"
        )
        break unless (response && response.status == 200 && list = safe_json(response.body))
        all_tools.concat(list)
        params = next_page_params(response)
      end
      all_tools
    end

    # The publicly accessible feed does have to be cached.
    def public_list_as_json
      self.class.fetch_from_cache do
        public_list.to_json
      end
    end

    def public_list
      external_tools_list.each_with_object({}) do |tool, hash|
        hash[tool['name']] = tool['id']
      end
    end

    def reset_external_tool(tool_id, config_url)
      canvas_url = "accounts/#{settings.account_id}/external_tools/#{tool_id}?config_type=by_url&config_url=#{config_url}"
      request_uncached(canvas_url, '_reset_external_tool', {
        method: :put
      })
    end

  end
end
