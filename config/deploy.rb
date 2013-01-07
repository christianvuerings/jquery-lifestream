require "rvm/capistrano"
require "bundler/capistrano"
require "config/settings/server_config"

set :rvm_ruby_string, 'jruby-1.7.1@calcentral'

settings = ServerConfig.get_settings(Dir.home + "/.calcentral_config/server_config.yml")

set :application, "CalCentral"
set :repository, settings.common.repository

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names

role(:sandbox_dev_host) {
  settings.sandbox.servers << { :branch => settings.sandbox.branch, :project_root => settings.sandbox.root }
}
role(:calcentral_dev_host) { settings.dev.servers }
set :user, settings.common.user
set :branch, settings.common.branch
set :project_root, settings.common.root

# Calcentral_dev is the IST configured server setup we have for calcentral-dev.berkeley.edu. It
# currently consists of 3 app servers, a shared postgres instance, ? memcache servers and ? elasticsearch
# servers.
namespace :calcentral_dev do
  desc "Update and restart the calcentral_dev machine"
  task :update, :roles => :calcentral_dev_host do
    # Take everything offline first.
    run "touch /var/www/html/calcentral/calcentral-in-maintenance"
    script_folder = project_root + ("/script")
    run "cd #{script_folder}; ./stop-trinidad.sh"
    # Run db migrate on the first app server
    servers = find_servers_for_task(current_task)
    rake = fetch(:rake, 'bundle exec rake')
    rails_env = fetch(:rails_env, 'production')

    transaction do
      servers.each_with_index do |server, index|
        run "cd #{project_root}; git fetch origin; git checkout -qf #{branch}; git reset --hard HEAD; git pull --quiet --summary"
        run "cd #{project_root}; RAILS_ENV=#{fetch(:rails_env, 'production')} bundle install"
        if (index == 0)
          logger.debug "---- Server: #{server.host} running migrate in transaction on offline app servers"
          run "cd #{project_root}; #{rake} db:migrate RAILS_ENV=#{rails_env} "
        end
      end
    end
    servers.each do |server|
      run "cd #{script_folder}; ./update-restart.sh"
      run "rm /var/www/html/calcentral/calcentral-in-maintenance"
    end
  end
end

# Sandbox_dev is the sandbox testing server that we have setup in 117. It sits on a old macbook
# and runs headless, used primarily for demos and other testing/experimental purposes.
namespace :sandbox_dev_host do
  desc "Update and restart the sandbox_dev machine"
  task :update, :roles => :sandbox_dev_host do
    rake = fetch(:rake, 'bundle exec rake')
    rails_env = fetch(:rails_env, 'production')
    find_servers_for_task(current_task).each do |server|
      run "cd #{server.options[:project_root]}; git fetch ets; git checkout -qf #{server.options[:branch]}; git reset --hard HEAD; git clean -f; git pull --quiet --summary"
      run "cd #{server.options[:project_root]}; RAILS_ENV=#{fetch(:rails_env, 'production')} bundle install"
      run "cd #{server.options[:project_root]}; #{rake} db:migrate RAILS_ENV=#{rails_env} "
      run "cd #{server.options[:project_root].concat('/script')}; ./update-restart.sh"
    end
  end
end
