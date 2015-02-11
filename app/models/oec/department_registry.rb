module Oec
  class DepartmentRegistry < Set

    attr_reader :biology_relationship_matchers
    attr_reader :biology_dept_name

    def initialize(dept_set = Settings.oec.departments)
      super dept_set
      @biology_dept_name = 'BIOLOGY'
      @biology_relationship_matchers = { 'MCELLBI' => ' 1A[L]?', 'INTEGBI' => ' 1B[L]?' }
      if include? @biology_dept_name
        merge @biology_relationship_matchers.keys
      else
        @biology_relationship_matchers.each_key do |dept_name|
          if include? dept_name
            add @biology_dept_name
            merge @biology_relationship_matchers.keys
            break
          end
        end
      end
    end

  end
end
