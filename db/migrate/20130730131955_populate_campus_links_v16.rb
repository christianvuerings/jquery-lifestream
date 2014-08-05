class PopulateCampusLinksV16 < ActiveRecord::Migration
  def self.up
    Links::CampusLinkLoader.delete_links!
    Links::CampusLinkLoader.load_links! "/public/json/campuslinks_v16.json"
  end

end
