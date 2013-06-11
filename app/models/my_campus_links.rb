class MyCampusLinks < MyMergedModel

=begin

  NOTES:

  - Navigation consists of Main Categories, Subcategories, and On-page categories
  - A Section is defined as a unique aggregate of MainCat/SubCat/PageCat
  - A single Categories table serves all three purposes by being referred to thrice in the Sections model
  - A Link can belong to multiple Sections; a Section consists of multiple links
  - Links (or their URLs) are guaranteed unique
  - RailsAdmin is whitelisting only the Models we want to display (in rails_admin.rb)
  - RailsAdmin comes with an optional History feature to track who changed what, but it's disabled here.

=end

  def get_feed_internal
    # Feed consists of two primary sections: Navigation and Links
    links = []
    navigation = []

    # Begin navigation section
    main_nav_top = {
      "label" => "",
      "categories" => [
        {
          "id" => "",
          "name" => "Campus Pages"
        }
      ]
    }
    navigation.push(main_nav_top)

    @maincats = LinkCategory.where("root_level = ?", true)
    @maincats.each do |cat|
      @section = {
        "label" => cat.name,
        "categories" => get_subsections_for_nav(cat)
      }
    navigation.push(@section)

    end

    # End Navigation section

    # Begin Links section
    @all_links = Link.where("published = ?", true)
    @all_links.each do |link|
      links.push({
        "name" => link.name,
        "description" => link.description,
        "url" => link.url,
        "roles" => get_roles_for_link(link),
        "categories" => get_cats_for_link(link)
      })
    end
    data = {"links" => links, "navigation" => navigation}

    # End Links section
  end

  # Given a top-level category, get names and slugs of subcats for navigation
  def get_subsections_for_nav(cat)
    categories = []
    # Find the unique subsections associated with this main category
    subsects = LinkSection.where("link_root_cat_id = ?", cat.id).select(:link_top_cat_id).uniq
    subsects.each do |subsection|
      categories.push({"id" => subsection.link_top_cat.slug, "name" => subsection.link_top_cat.name})
    end
    categories = categories.sort_by { |n| n["name"] } # Alphabetize left-nav subsections
    categories
  end

  # Given a link, return an array of the categories it lives in by examining its host sections
  def get_cats_for_link(link)
    categories = []
    sections = link.link_sections
    sections.each do |section|
      catlist = {"topcategory" => section.link_top_cat.name, "subcategory" => section.link_sub_cat.name}
      categories.push(catlist)
    end
    categories
  end

  # Given a link, return a dict of the user_roles allowed to view it
  def get_roles_for_link(link)
    roles = {"student" => false, "staff" => false, "faculty" => false}
    link.user_roles.each do |linkrole|
      roles["student"] = true if linkrole.slug == "student"
      roles["staff"] = true if linkrole.slug == "staff"
      roles["faculty"] = true if linkrole.slug == "faculty"
    end
    roles
  end

end
