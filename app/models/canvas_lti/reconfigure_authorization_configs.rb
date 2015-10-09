module CanvasLti
  # Reconfigured CAS Authentication Base URL for cloud Canvas applications used for development/testing
  module ReconfigureAuthorizationConfigs
    extend self
    include ClassLogger

    def reconfigure(correct_cas_url, canvas_hosts)
      canvas_hosts.each do |canvas_host|
        worker = Canvas::AuthorizationConfigs.new(url_root: canvas_host)
        if (authorization_configs = worker.authorization_configs[:body])
          authorization_configs.each do |config|
            if config['auth_type'] == 'cas'
              if config['auth_base'] != correct_cas_url
                logger.info "Reconfiguring CAS URL from #{config['auth_base']} to #{correct_cas_url} for #{canvas_host}"
                config['auth_base'] = correct_cas_url
                worker.reset_authorization_config(config['id'], config)
              else
                logger.info "CAS Server URL matches for #{canvas_host}. No action taken"
              end
            elsif config['position'] == 1
              logger.fatal "Non-CAS authentication is set as primary login method! #{config}"
            end
          end
        end
      end
    end

  end
end
