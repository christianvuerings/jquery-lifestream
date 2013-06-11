class UserRole < ActiveRecord::Base
  attr_accessible :name, :slug, :link_ids
  has_and_belongs_to_many :links
end
