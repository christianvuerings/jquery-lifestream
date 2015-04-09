module Links
  class CampusLinkLoader

    def self.delete_links!
      # TODO can we reset the auto-ids?
      sql = <<-SQL
      DELETE FROM link_sections_links;
      DELETE FROM link_categories_link_sections;
      DELETE FROM link_sections;
      DELETE FROM links_user_roles;
      DELETE FROM link_categories;
      DELETE FROM links;
      SQL
      Links::Link.connection.execute sql
    end

    def self.load_links!(filename)
      student = Links::UserRole.find_or_create_by(name: 'Student') {|ur| ur.slug = 'student'}
      staff = Links::UserRole.find_or_create_by(name: 'Staff') {|ur| ur.slug = 'staff'}
      faculty = Links::UserRole.find_or_create_by(name: 'Faculty') {|ur| ur.slug = 'faculty'}

      begin
        file = File.open("#{Rails.root}#{filename}")
        contents = File.read(file)
        json = JSON.parse(contents)

        ancestry = {}

        json["navigation"].each do |root_node|
          unless root_node["label"] == ""
            root = root_node["label"]
            root_cat = Links::LinkCategory.create(
              {
                :name => root,
                :slug => root.downcase,
                :root_level => true
              })

            root_node["categories"].each do |top_category_node|
              top_cat = Links::LinkCategory.create(
                {
                  :name => top_category_node["name"],
                  :slug => top_category_node["id"],
                  :root_level => false
                })
              ancestry[top_category_node["name"]] = {}
              ancestry[top_category_node["name"]]["top_cat"] = top_cat
              ancestry[top_category_node["name"]]["root_cat"] = root_cat
            end
          end
        end

        json["links"].each do |link_node|
          roles = []
          if link_node["roles"]
            if link_node["roles"]["student"]
              roles << student.id
            end
            if link_node["roles"]["faculty"]
              roles << faculty.id
            end
            if link_node["roles"]["staff"]
              roles << staff.id
            end
          end

          this_links_sections = []

          link_node["categories"].each do |category_node|
            top_cat_name = category_node["topcategory"]
            sub_cat_name = category_node["subcategory"]

            sub_cat = Links::LinkCategory.where({:name => sub_cat_name}).first_or_create(
              {
                :slug => sub_cat_name.downcase,
                :root_level => false
              })

            section = Links::LinkSection.where(
              {
                :link_root_cat_id => ancestry[top_cat_name]["root_cat"].id,
                :link_top_cat_id => ancestry[top_cat_name]["top_cat"].id,
                :link_sub_cat_id => sub_cat.id
              }).first_or_create
            this_links_sections << section.id
          end

          Links::Link.create(
            {
              :name => link_node["name"],
              :description => link_node["description"],
              :published => true,
              :url => link_node["url"],
              :link_section_ids => this_links_sections,
              :user_role_ids => roles
            }, :force => true)

        end

      ensure
        file.close
      end
    end
  end
end
