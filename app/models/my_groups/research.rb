class MyGroups::Research
  include MyGroups::GroupsModule

  def fetch
    ResearchUserProxy.new({:user_id => @uid}).get_sites
  end

end
