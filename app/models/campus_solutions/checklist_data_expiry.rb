module CampusSolutions
  module ChecklistDataExpiry
    def self.expire(uid=nil)
      [CampusSolutions::Checklist, MyTasks::Merged].each do |klass|
        klass.expire uid
      end
      # TODO remove this next line after SISRP-7420 gets merged
      CampusSolutions::Checklist.expire nil
    end
  end
end
