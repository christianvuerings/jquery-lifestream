namespace :backstage do
  desc "Starts background jobs for CalCentral"
  task :start do
    # hack in some dependency loading that the Rails framework would do for us, if this were full Rails.
    require "lib/workers/backstage"
    require "lib/oauth2_data"
    require_all "lib/proxies"
    require "app/models/user_auth"
    require "app/models/user_data"

    Backstage.start
  end

  desc "Stops the CalCentral background jobs"
  task :stop do
    require "lib/workers/process_control"
    ProcessControl.grep_kill(/backstage:start/, "TERM")
  end

  desc "Log information about the CalCentral background jobs"
  task :stats do
    require "lib/workers/process_control"
    ProcessControl.grep_kill(/backstage:start/, "USR1")
  end

end
