class PopulateCampusLinksV17 < ActiveRecord::Migration
  def self.up
    CampusLinkLoader.delete_links!
    CampusLinkLoader.load_links! "/public/json/campuslinks_v17.json"
  end

end
