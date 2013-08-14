class PopulateCampusLinksV17B < ActiveRecord::Migration
  def self.up
    CampusLinkLoader.delete_links!
    CampusLinkLoader.load_links! "/public/json/campuslinks_v17_b.json"
  end

end
