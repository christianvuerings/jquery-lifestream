module Canvas
  class ExternalTools < Proxy

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
      response = paged_get "#{@api_root}/external_tools"
      response[:body]
    end

    def reset_external_tool_config_by_url(tool_id, config_url)
      canvas_url = "#{@api_root}/external_tools/#{tool_id}?config_type=by_url&config_url=#{config_url}"
      wrapped_put canvas_url
    end

    def find_canvas_course_tab(tool_id)
      course_site_tab_list.find { |tab| tab['id'].end_with? "_#{tool_id}" }
    end

    def hide_course_site_tab(tab)
      update_course_site_tab_hidden(tab, true)
    end

    def show_course_site_tab(tab)
      update_course_site_tab_hidden(tab, false)
    end

    def create_external_tool_by_xml(tool_name, xml_string)
      wrapped_post "#{@api_root}/external_tools", {
        'name' => tool_name,
        'config_type' => 'by_xml',
        'config_xml' => xml_string,
        'consumer_key' => Settings.canvas_proxy.lti_key,
        'shared_secret' => Settings.canvas_proxy.lti_secret
      }
    end

    def reset_external_tool_by_xml(tool_id, xml_string)
      wrapped_post "#{@api_root}/external_tools/#{tool_id}", {
        'config_type' => 'by_xml',
        'config_xml' => xml_string,
        'consumer_key' => Settings.canvas_proxy.lti_key,
        'shared_secret' => Settings.canvas_proxy.lti_secret
      }
    end

    # A simple pass-through utility method for one-off tests and fixes of
    # LTI app configurations.
    def modify_external_tool(tool_id, parameters)
      wrapped_put "#{@api_root}/external_tools/#{tool_id}", parameters
    end

    private

    def update_course_site_tab_hidden(tab, set_to_hidden)
      begin
        # Take a snapshot of tab configs before performing update
        tabs_before_update = course_site_tabs_by_id
        tab_id = tab['id']
        updated_tab = update_course_site_tab(tab_id, options_for_tab_update(tab, set_to_hidden))
        unless updated_tab && set_to_hidden == property_as_boolean(updated_tab, 'hidden')
          raise Errors::ProxyError.new("Failed to set hidden=#{set_to_hidden} on tab #{tab_id} of Canvas:#{@api_root}", uid: @uid, tab: tab)
        end
        # Canvas Tab API has a bug whereby 'hidden' value is updated on un-targeted tabs. We must fix collateral damage, if any.
        course_site_tabs_by_id.each do |id, tab_after_update|
          tab_before_update = tabs_before_update[id]
          # Only inspect the extraneous tabs
          if id != tab_id && tab_before_update && tab_before_update['hidden'] != tab_after_update['hidden']
            original_hidden_value = property_as_boolean(tab_before_update, 'hidden')
            logger.warn "Restore #{tab_after_update['label']} to hidden=#{original_hidden_value} on #{@api_root}"
            update_course_site_tab(id, options_for_tab_update(tab_after_update, original_hidden_value))
          end
        end
        updated_tab
      rescue => exception
        logger.error "Problem updating hidden=#{set_to_hidden} on tab #{tab_id} of Canvas:#{@api_root}. Abort!"
        raise exception
      end
    end

    def property_as_boolean(tab, property_name)
      # Canvas Tab API docs have 'hidden' property as type String
      'true'.casecmp(tab[property_name].to_s) == 0
    end

    def course_site_tab_list
      response = wrapped_get "#{@api_root}/tabs"
      response[:statusCode] == 200 ? response[:body] : {}
    end

    def course_site_tabs_by_id
      Hash[course_site_tab_list.map { |t| [t['id'], t] }]
    end

    def update_course_site_tab(tab_id, options)
      url = "#{@api_root}/tabs/#{tab_id}"
      response = raw_request(url, options)
      if response.status == 200
        logger.info "Updated course site_tab with url=#{url} and options: #{options}"
        safe_json response.body
      else
        raise Errors::ProxyError.new("Failed to update tab #{tab_id} of Canvas:#{@api_root}", response: response, url: url, uid: @uid)
      end
    end

    def options_for_tab_update(tab, set_to_hidden)
      {
        :method => :put,
        :body => {
          'id' => tab['id'],
          'hidden' => set_to_hidden,
          'position' => tab['position'],
          'visibility' => 'public'
        }
      }
    end

    def mock_interactions
      on_request(uri_matching: "#{@api_root}/external_tools", method: :get).
        respond_with_file('fixtures', 'json', 'canvas_external_tools.json')

      on_request(uri_matching: "#{@api_root}/external_tools", method: :post).
        respond_with_file('fixtures', 'json', 'canvas_create_external_tool.json')

      on_request(uri_matching: "#{@api_root}/external_tools", method: :put, query_including: {'config_type' => 'by_url'}).
        respond_with_file('fixtures', 'json', 'canvas_reset_external_tool.json')

      on_request(uri_matching: "#{@api_root}/external_tools", method: :put, query_including: {'config_type' => 'by_xml'}).
        respond_with_file('fixtures', 'json', 'canvas_reset_external_tool_by_xml.json')
    end

  end
end
