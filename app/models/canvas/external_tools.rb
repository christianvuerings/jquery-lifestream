module Canvas
  class ExternalTools < Proxy

    include SafeJsonParser

    # The publicly accessible feed does have to be cached.
    def self.public_list_as_json
      fetch_from_cache do
        Canvas::ExternalTools.public_list.to_json
      end
    end

    def self.public_list
      list_template = {
        :global_tools => Settings.canvas_proxy.account_id,
        :official_course_tools => Settings.canvas_proxy.official_courses_account_id
      }
      public_list = {}
      list_template.each do |key, account_id|
        external_tool_worker = self.new(:canvas_account_id => account_id)
        public_list[key] = external_tool_worker.external_tools_list.each_with_object({}) do |tool, hash|
          hash[tool['name']] = tool['id']
        end
      end
      public_list
    end

    # Unlike other Canvas proxies, this can make requests to multiple Canvas servers.
    def initialize(options = {})
      super(options)
      default_options = {canvas_account_id: @settings.account_id }
      options.reverse_merge!(default_options)
      @canvas_account_id = options[:canvas_account_id]

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
          "accounts/#{@canvas_account_id}/external_tools?#{params}",
          "_external_tools"
        )
        break unless (response && response.status == 200 && list = safe_json(response.body))
        all_tools.concat(list)
        params = next_page_params(response)
      end
      all_tools
    end

    def reset_external_tool(tool_id, config_url)
      canvas_url = "accounts/#{@canvas_account_id}/external_tools/#{tool_id}?config_type=by_url&config_url=#{config_url}"
      request_uncached(canvas_url, '_reset_external_tool', {
        method: :put
      })
    end

  end
end
