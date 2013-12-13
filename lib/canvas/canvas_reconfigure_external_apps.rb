module CanvasReconfigureExternalApps
  extend self
  include ClassLogger

  def app_to_xml
    {
      'course_provision' => 'lti_course_provision',
      'rosters' => 'lti_roster_photos',
      'user_provision' => 'lti_user_provision',
      'course_add_user' => 'lti_course_add_user'
    }
  end

  def reconfigure_external_apps(reachable_xml_host, canvas_hosts_to_calcentrals)
    lti_subpath = 'canvas/embedded/'
    # The interesting app URLs look like: "https://cc-dev.example.com/canvas/embedded/rosters".
    url_regex = /https:\/\/(?<app_host>.+)\/#{lti_subpath}(?<app>.+)/
    canvas_hosts_to_calcentrals.each do |mapping|
      canvas_host = mapping[:host]
      calcentral_host = mapping[:calcentral]
      proxy = CanvasExternalToolsProxy.new({url_root: canvas_host})
      external_tools_list = proxy.external_tools_list
      external_tools_list.each do |tool_config|
        tool_url = tool_config['url']
        if (parsed_url = url_regex.match(tool_url))
          current_app_host = parsed_url[:app_host]
          app_name = parsed_url[:app]
          if current_app_host == calcentral_host
            logger.debug("App #{app_name} on #{canvas_host} already points to #{calcentral_host}")
          else
            if app_to_xml[app_name]
              logger.warn("Resetting app #{app_name} on #{canvas_host} to #{calcentral_host}")
              tool_id = tool_config['id']
              app_config_url = "#{reachable_xml_host}/canvas/#{app_to_xml[app_name]}.xml?app_host=#{calcentral_host}"
              proxy.reset_external_tool(tool_id, app_config_url)
            else
              logger.warn("No known XML for app #{app_name} on #{canvas_host}, skipping")
            end
          end
        end
      end

    end
  end

end
