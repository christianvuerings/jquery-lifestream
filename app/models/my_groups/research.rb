class MyGroups::Research
  include MyGroups::GroupsModule

  def fetch
    sites = []
    return sites unless ResearchUserProxy.access_granted?(@uid)
    research_sites = MyResearchGroups.new(@uid).get_feed_internal
    research_sites[:research].each_with_index do |group_site,index|
      sites << {
        id: index,
        emitter: "researchhub",
        name: group_site["title"],
        short_description: group_site["description"],
        site_url: "https://hub-qa.berkeley.edu/page/site/#{group_site["shortName"]}/dashboard"
      }
    end
    sites
  end

end
