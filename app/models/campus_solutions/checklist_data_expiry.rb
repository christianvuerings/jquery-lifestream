module CampusSolutions
  module ChecklistDataExpiry
    def self.expire(uid=nil)
      [CampusSolutions::Checklist, CampusSolutions::MyChecklist, MyTasks::Merged].each do |klass|
        klass.expire uid
      end
    end
  end
end
