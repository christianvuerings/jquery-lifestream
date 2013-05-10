namespace :backstage do
  desc "Starts background jobs for CalCentral"
  task :start do
    require "lib/workers/backstage"
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
