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
        :globalTools => Settings.canvas_proxy.account_id,
        :officialCourseTools => Settings.canvas_proxy.official_courses_account_id
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

      if (canvas_course_id = options[:canvas_course_id])
        @api_root = "courses/#{canvas_course_id}"
      else
        @api_root = "accounts/#{options[:canvas_account_id]}"
      end

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
          "#{@api_root}/external_tools?#{params}",
          "_external_tools"
        )
        break unless (response && response.status == 200 && list = safe_json(response.body))
        all_tools.concat(list)
        params = next_page_params(response)
      end
      all_tools
    end

    def reset_external_tool_config_by_url(tool_id, config_url)
      canvas_url = "#{@api_root}/external_tools/#{tool_id}?config_type=by_url&config_url=#{config_url}"
      request_uncached(canvas_url, '_reset_external_tool', {
        method: :put
      })
    end

    def find_canvas_course_tab(tool_id)
      response = request_uncached("#{@api_root}/tabs", '_find_canvas_course_tab', { method: :get })
      all_tabs = response && safe_json(response.body)
      matching_tab = all_tabs && all_tabs.select { |tab| tab['id'].ends_with? "_#{tool_id}" }
      matching_tab ? matching_tab.first : nil
    end

    def hide_course_site_tab(tab_id)
      update_course_site_tab_hidden(tab_id, true)
    end

    def show_course_site_tab(tab_id)
      update_course_site_tab_hidden(tab_id, false)
    end

    def create_external_tool_by_xml(tool_name, xml_string)
      parameters = {
          'name' => tool_name,
          'config_type' => 'by_xml',
          'config_xml' => xml_string,
          'consumer_key' => Settings.canvas_proxy.lti_key,
          'shared_secret' => Settings.canvas_proxy.lti_secret
        }
      canvas_url = "#{@api_root}/external_tools"
      response = request_uncached(canvas_url, '_create_external_tool', {
          method: :post,
          body: parameters
        })
      response ? safe_json(response.body) : nil
    end

    def reset_external_tool_by_xml(tool_id, xml_string)
      parameters = {
          'config_type' => 'by_xml',
          'config_xml' => xml_string,
          'consumer_key' => Settings.canvas_proxy.lti_key,
          'shared_secret' => Settings.canvas_proxy.lti_secret
        }
      canvas_url = "#{@api_root}/external_tools/#{tool_id}"
      response = request_uncached(canvas_url, '_reset_external_tool_by_xml', {
          method: :put,
          body: parameters
        })
      response ? safe_json(response.body) : nil
    end

    # A simple pass-through utility method for one-off tests and fixes of
    # LTI app configurations.
    def modify_external_tool(tool_id, parameters)
      canvas_url = "#{@api_root}/external_tools/#{tool_id}"
      response = request_uncached(canvas_url, '_modify_external_tool', {
          method: :put,
          body: parameters
        })
      response ? safe_json(response.body) : nil
    end

    private

    def update_course_site_tab_hidden(tab_id, set_to_hidden)
      begin
        options = {
          :method => :put,
          :body => { 'hidden' => set_to_hidden },
        }
        url = "#{@api_root}/tabs/#{tab_id}"
        response = request_uncached(url, '_update_course_site_tab_hidden', options)
        tab = response && safe_json(response.body)
        is_tab_now_showing = tab && !tab['hidden']
        if is_tab_now_showing == set_to_hidden
          raise Errors::ProxyError.new("Failed to set hidden=#{set_to_hidden} on tab #{tab_id} of Canvas:#{@api_root}", response: response, url: url, uid: @uid)
        end
        tab
      rescue => exception
        logger.error "#{self.class.name} Problem updating hidden=#{set_to_hidden} on tab #{tab_id} of Canvas:#{@api_root}. Abort!"
        raise exception
      end
    end

  end
end
