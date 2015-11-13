module CampusSolutions
  module PersonDataExpiry
    def self.expire(uid=nil)
      [HubEdos::Person, HubEdos::Student, HubEdos::MyPerson, HubEdos::MyStudent].each do |klass|
        klass.expire uid
      end
    end
  end
end
