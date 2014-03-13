module Links
# TODO rename this class to LinkRole, it has nothing to do with users. It's used only as part of the Links::MyCampusLinks feature.
# Renaming will require a db migration.
  class UserRole < ActiveRecord::Base
    attr_accessible :name, :slug, :link_ids
    has_and_belongs_to_many :links
  end
end
