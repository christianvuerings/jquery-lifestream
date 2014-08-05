class PopulateCampusLinksV17 < ActiveRecord::Migration
  def self.up
    Links::CampusLinkLoader.delete_links!
    Links::CampusLinkLoader.load_links! "/public/json/campuslinks_v17.json"
  end

end
