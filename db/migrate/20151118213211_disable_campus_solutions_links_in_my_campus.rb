class DisableCampusSolutionsLinksInMyCampus < ActiveRecord::Migration
  def change
    Links::CampusLinkLoader.delete_links!
    Links::CampusLinkLoader.load_links! '/public/json/campuslinks.json'
  end
end
