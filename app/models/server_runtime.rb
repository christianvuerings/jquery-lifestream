class ServerRuntime
  def self.get_settings
    @server_settings ||= init_settings
    @server_settings
  end

  # Only needs to happen once, since the settings shouldn't change after the server starts
  def self.init_settings
    settings = {}
    settings["first_visited"] = `date`.strip
    settings["git_commit"] = `git log --pretty=format:'%H' -n 1`
    settings["hostname"] = `hostname -s`.strip
    settings
  end
end