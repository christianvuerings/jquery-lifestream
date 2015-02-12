module Berkeley
  class SummerSubTerm < ActiveRecord::Base
    include ActiveRecordHelper, ClassLogger
    extend Cache::Cacheable

    attr_accessible :year, :sub_term_code, :start, :end
    attr_reader :classes_start, :classes_end

    validates :year, presence: true
    validates :start, presence: true
    validates :sub_term_code, presence: true
    validates :end, presence: true

    after_initialize do |subterm|
      @classes_start = subterm.start.in_time_zone.to_datetime
      @classes_end = subterm.end.in_time_zone.to_datetime.end_of_day
    end

    def slug
      "summer-subterm-#{sub_term_code}-#{year}"
    end
  end
end
