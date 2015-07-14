module CanvasLti
  class ReconfigureExternalApps
    include ClassLogger
    include CanvasLti::ExternalAppConfigurations

    # This resets the existing tool configurations of a hard-coded list of Canvas servers to point
    # to non-production LTI providers, but using the configurations of the production Junction server as a starting
    # point. We take this roundabout route because the code sends the revised configurations by URL, and
    # externally-hosted Canvas is not able to reach the URLs of our non-production Junction servers.
    # However, this means the code can only communicate tool configurations which are known to production
    # Junction; e.g., upcoming new apps can't be added to Dev/QA environments.
    def reset_external_app_hosts_by_url(reachable_xml_host, canvas_hosts_to_calcentrals)
      canvas_hosts_to_calcentrals.each do |mapping|
        canvas_host = mapping[:host]
        calcentral_host = "https://#{mapping[:calcentral]}"
        refresh_accounts.each do |canvas_account_id|
          proxy = Canvas::ExternalTools.new(url_root: canvas_host, canvas_account_id: canvas_account_id)
          external_tools_list = proxy.external_tools_list
          external_tools_list.each do |tool_config|
            tool_url = tool_config['url']
            if (parsed_url = parse_host_and_code_from_launch_url(tool_url))
              current_app_host = parsed_url[:app_host]
              app_code = parsed_url[:app_code]
              if current_app_host == calcentral_host
                logger.debug "App #{app_code} on #{canvas_host} already points to #{calcentral_host}"
              else
                if (xml_name = app_code_to_xml_name(app_code))
                  logger.warn "Resetting app #{app_code} on #{canvas_host} to #{calcentral_host}"
                  tool_id = tool_config['id']
                  app_config_url = "#{reachable_xml_host}/canvas/#{xml_name}.xml?app_host=#{calcentral_host}"
                  proxy.reset_external_tool_config_by_url(tool_id, app_config_url)
                else
                  logger.warn "No known XML for app #{app_code} on #{canvas_host}, skipping"
                end
              end
            end
          end
        end
      end
    end

    # Unlike reset_external_app_hosts_by_url, this will always overwrite an existing configuration whether
    # there are visible changes needed or not. This supports changes to the LTI shared_secret.
    def configure_external_app_by_xml(app_host, app_code)
      unless (app_definition = lti_app_definitions[app_code]) && (app_account = app_definition[:account])
        return {status: 'unknown'}
      end
      xml_string = render_local_xml_config(app_host, app_definition[:xml_name])
      external_tools_proxy = Canvas::ExternalTools.new(canvas_account_id: app_account)
      if (existing_config = existing_app_config(app_account, app_code))
        tool_id = existing_config['id']
        log_message = "Overwriting configuration for #{app_code}, ID #{tool_id}"
        existing_host = parse_host_and_code_from_launch_url(existing_config['url'])[:app_host]
        log_message.concat(", provider from #{existing_host} to #{app_host}") if existing_host != app_host
        log_message.concat(", name from #{existing_config['name']} to #{app_definition[:app_name]}") if existing_config['name'] != app_definition[:app_name]
        logger.warn log_message
        if (response = external_tools_proxy.reset_external_tool_by_xml(tool_id, xml_string))
          {
            app_id: tool_id,
            status: 'overwritten'
          }
        else
          {
            app_id: tool_id,
            status: 'error'
          }
        end
      else
        logger.warn "Adding configuration for #{app_code} to account #{app_account}"
        if (response = external_tools_proxy.create_external_tool_by_xml(app_definition[:app_name], xml_string))
          {
            app_id: response['id'],
            status: 'added'
          }
        else
          {
            status: 'error'
          }
        end
      end
    end

    def existing_app_config(account_id, app_code)
      @accounts ||= {}
      @accounts[account_id] ||= Canvas::ExternalTools.new(canvas_account_id: account_id).external_tools_list
      existing_tools = @accounts[account_id]
      match_idx = existing_tools.index do |config|
        tool_url = config['url']
        if (parsed_url = parse_host_and_code_from_launch_url(tool_url))
          tool_app_code = parsed_url[:app_code]
          (tool_app_code == app_code)
        end
      end
      if match_idx
        existing_tools[match_idx]
      else
        nil
      end
    end


    # Add or overwrite all Junction-defined LTI apps on the default Canvas host.
    # (Deletion of undefined apps from Canvas accounts will have to be handled manually.)
    def configure_all_apps_from_current_host(options = {})
      app_provider_host = options[:app_provider_host] || Settings.canvas_proxy.app_provider_host
      results = {}
      lti_app_definitions.each_key do |app_code|
        results[app_code] = configure_external_app_by_xml(app_provider_host, app_code)
      end
      logger.warn "Reset all defined LTI apps: #{results}"
      results
    end

    def render_local_xml_config(app_host, xml_name)
      app_code = xml_name_to_app_code(xml_name)
      output_buffer = ActionView::Base.new('app/views/canvas_lti').render(file: xml_name, format: 'xml',
        locals: {:@launch_url_for_app => launch_url_for_host_and_code(app_host, app_code)})
      # A simple ".to_s" will leave the ActionView::OutputBuffer as is and cause an exception to be thrown when
      # Faraday attempts to encode the parameter.
      String.new(output_buffer)
    end

  end
end
