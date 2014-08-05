class CreateCampusLinksTables < ActiveRecord::Migration
  def self.up
    create_table :links do |t|
      t.string :name
      t.string :url
      t.string :description
      t.boolean :published, :default => true
      t.timestamps
    end

    create_table :link_sections do |t|
      t.integer :link_root_cat_id
      t.integer :link_top_cat_id
      t.integer :link_sub_cat_id
      t.timestamps
    end

    create_table :link_categories, :force => true do |t|
      t.string :name, :null => false
      t.string :slug, :null => false
      t.boolean :root_level, :default => false
      t.timestamps
    end

    create_table :user_roles do |t|
      t.string :name
      t.string :slug
    end

    create_table :links_user_roles, :id => false do |t|
      t.references :link
      t.references :user_role
    end

    create_table :link_categories_link_sections, :id => false do |t|
      t.references :link_category
      t.references :link_section
    end

    create_table :link_sections_links, :id => false do |t|
      t.references :link_section
      t.references :link
    end

  end

  def self.down
    drop_table :link_sections_links
    drop_table :link_categories_link_sections
    drop_table :links_user_roles
    drop_table :links
    drop_table :link_sections
    drop_table :link_categories
    drop_table :user_roles
  end
end
