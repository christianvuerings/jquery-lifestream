# TODO collapse this class into ResearchHub::Proxy
module MyGroups
  class Research
    include GroupsModule

    def fetch
      ResearchHub::Proxy.new({:user_id => @uid}).get_sites
    end

  end
end
