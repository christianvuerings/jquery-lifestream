class ServerRuntime
  def self.get_settings
    @server_settings ||= init_settings
    @server_settings
  end

  # Only needs to happen once, since the settings shouldn't change after the server starts
  def self.init_settings
    Rails.logger.info "Initializing settings"

    settings = {}
    settings["first_visited"] = `date`.strip
    settings["git_commit"] = `git log --pretty=format:'%H' -n 1`
    settings["hostname"] = `hostname -s`.strip

    migrations = Dir.glob("#{Rails.root}/db/migrate/*.rb")
    current_schema = File.basename(migrations.sort.last).split("_")[0]
    settings["versions"] = {
        "api" => File.open(Rails.root.join("versions", "api.txt")).read.strip,
        "application" => File.open(Rails.root.join("versions", "application.txt")).read.strip,
        "current_db_schema" => current_schema,
        "previous_release_db_schema" => File.open(Rails.root.join("versions", "previous_release_db_schema.txt")).read.strip
    }
    settings
  end
end