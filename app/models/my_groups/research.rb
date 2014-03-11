class MyGroups::Research
  include MyGroups::GroupsModule

  def fetch
    Proxy.new({:user_id => @uid}).get_sites
  end

end
