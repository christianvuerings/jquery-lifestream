module CampusSolutions
  module PersonDataExpiry
    def self.expire(uid=nil)
      [HubEdos::Student, HubEdos::MyStudent].each do |klass|
        klass.expire uid
      end
    end
  end
end
