class LinkCategory < ActiveRecord::Base

  attr_accessible :name, :slug, :root_level
  has_and_belongs_to_many :link_sections

  validates :name, :presence  => true
  validates :slug, :presence  => true
  validates_uniqueness_of :name, :slug

end
