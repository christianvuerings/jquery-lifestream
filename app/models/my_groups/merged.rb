class MyGroups::Merged  < MyMergedModel

  def get_feed_internal
    groups = []
    [
      MyGroups::Callink,
      MyGroups::Canvas,
      MyGroups::Sakai
    ].each do |provider|
      groups.concat(provider.new(@uid).fetch)
    end
    groups.sort! { |x, y| x[:name].casecmp(y[:name]) }
    {
      groups: groups
    }
  end

end
