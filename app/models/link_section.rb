class LinkSection < ActiveRecord::Base

  attr_accessible :link_root_cat_id
  attr_accessible :link_top_cat_id
  attr_accessible :link_sub_cat_id

  # This class is related to another class via three different names
  belongs_to :link_root_cat, :foreign_key => "link_root_cat_id", :class_name => "LinkCategory"
  belongs_to :link_top_cat, :foreign_key => "link_top_cat_id", :class_name => "LinkCategory"
  belongs_to :link_sub_cat, :foreign_key => "link_sub_cat_id", :class_name => "LinkCategory"

  validates :link_root_cat, :presence  => true
  validates :link_top_cat, :presence  => true
  validates :link_sub_cat, :presence  => true

end
