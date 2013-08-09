class PopulateCampusLinksV16 < ActiveRecord::Migration
  def self.up
    CampusLinkLoader.delete_links!
    CampusLinkLoader.load_links! "/public/json/campuslinks_v16.json"
  end

end
