class UpdateCampusLinksMay2015 < ActiveRecord::Migration
  def self.up
    Links::CampusLinkLoader.delete_links!
    Links::CampusLinkLoader.load_links! "/public/json/campuslinks.json"
  end
end
