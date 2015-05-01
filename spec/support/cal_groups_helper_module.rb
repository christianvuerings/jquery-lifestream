module CalGroupsHelperModule

  def expect_valid_group_data(group)
    [:index, :name, :qualifiedName, :uuid].each do |key|
      expect(group[key]).to be_present
    end
  end

  def expect_valid_member_data(member)
    [:id, :name].each do |key|
      expect(member[key]).to be_present
    end
  end

end
