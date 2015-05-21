class AddListDetailsToCanvasSiteMailingLists < ActiveRecord::Migration
  def change
    add_column :canvas_site_mailing_lists, :members_count, :integer
    add_column :canvas_site_mailing_lists, :populate_add_errors, :integer
    add_column :canvas_site_mailing_lists, :populate_remove_errors, :integer
  end
end
