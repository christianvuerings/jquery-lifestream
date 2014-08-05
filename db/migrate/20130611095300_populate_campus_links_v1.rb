class PopulateCampusLinksV1 < ActiveRecord::Migration
  def self.up
    Links::CampusLinkLoader.delete_links!
    Links::CampusLinkLoader.load_links! "/public/json/campuslinks.json"
  end

  def self.down
    Links::CampusLinkLoader.delete_links!
  end

end
