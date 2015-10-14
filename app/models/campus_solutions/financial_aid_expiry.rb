module CampusSolutions
  module FinancialAidExpiry
    def self.expire(uid=nil)
      [AidYears, FinancialAidData, MyAidYears, MyFinancialAidData].each do |klass|
        klass.expire uid
      end
    end
  end
end
