module Oec
  class SisImportSheet < Worksheet

    attr_reader :dept_code

    def initialize(export_dir, opts={})
      unless (@dept_code = opts.delete :dept_code)
        raise ArgumentError, 'dept_code option required'
      end
      opts[:filename] = "#{@dept_code}.csv"
      super(export_dir, opts)
    end

    def headers
      %w(
        COURSE_ID
        COURSE_ID_2
        COURSE_NAME
        CROSS_LISTED_FLAG
        CROSS_LISTED_NAME
        DEPT_NAME
        CATALOG_ID
        INSTRUCTION_FORMAT
        SECTION_NUM
        PRIMARY_SECONDARY_CD
        LDAP_UID
        SIS_ID
        FIRST_NAME
        LAST_NAME
        EMAIL_ADDRESS
        INSTRUCTOR_FUNC
        BLUE_ROLE
        EVALUATE
        DEPT_FORM
        EVALUATION_TYPE
        MODULAR_COURSE
        START_DATE
        END_DATE
      )
    end

  end
end
