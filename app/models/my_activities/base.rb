module MyActivities::Base

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    # This should be overwritten with the different proxy implementations
    def append!(uid, activities)
    end
  end
end
