class PopulateCampusLinksV17B < ActiveRecord::Migration
  def self.up
    Links::CampusLinkLoader.delete_links!
    Links::CampusLinkLoader.load_links! "/public/json/campuslinks_v17_b.json"
  end

end
