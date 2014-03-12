# TODO collapse this class into ResearchHub::Proxy
class MyGroups::Research
  include MyGroups::GroupsModule

  def fetch
    ResearchHub::Proxy.new({:user_id => @uid}).get_sites
  end

end
