class CampusData < OracleDatabase
  include ActiveRecordHelper

  def self.reg_status_translator
    @reg_status_translator ||= RegStatusTranslator.new
  end

  def self.educ_level_translator
    @educ_level_translator ||= EducLevelTranslator.new
  end

  def self.cal_residency_translator
    @cal_residency_translator ||= CalResidencyTranslator.new
  end

  def self.current_year
    Settings.sakai_proxy.current_terms_codes.first.term_yr
  end

  def self.current_term
    Settings.sakai_proxy.current_terms_codes.first.term_cd
  end

  def self.get_person_attributes(person_id)
    result = {}
    use_pooled_connection {
      log_access(connection, connection_handler, name)
      sql = <<-SQL
      select pi.ldap_uid, pi.student_id, pi.ug_grad_flag, pi.first_name, pi.last_name,
        pi.person_name, pi.email_address, pi.affiliations,
        reg.reg_status_cd, reg.educ_level, reg.admin_cancel_flag, reg.acad_blk_flag, reg.admin_blk_flag,
        reg.fin_blk_flag, reg.reg_blk_flag, reg.tot_enroll_unit, reg.cal_residency_flag
      from bspace_person_info_vw pi
      left outer join bspace_student_term_vw reg on
        ( reg.ldap_uid = pi.ldap_uid
          and reg.term_yr = #{connection.quote(current_year)}
          and reg.term_cd = #{connection.quote(current_term)}
        )
      where pi.ldap_uid = #{connection.quote(person_id)}
      SQL
      result = connection.select_one(sql)
    }
    if result
      result[:reg_status] = {
          :code => result["reg_status_cd"],
          :summary => self.reg_status_translator.status(result["reg_status_cd"]),
          :explanation => self.reg_status_translator.status_explanation(result["reg_status_cd"]),
          :needsAction => !self.reg_status_translator.is_registered(result["reg_status_cd"])
      }
      result[:units_enrolled] = result["tot_enroll_unit"]
      result[:education_level] = self.educ_level_translator.translate(result["educ_level"])
      result[:california_residency] = self.cal_residency_translator.translate(result["cal_residency_flag"])
      result['affiliations'] ||= ""
      result[:roles] = {
          :student => result['affiliations'].include?("STUDENT-TYPE-"),
          :faculty => result['affiliations'].include?("EMPLOYEE-TYPE-ACADEMIC"),
          :staff => result['affiliations'].include?("EMPLOYEE-TYPE-STAFF")
      }

    end
    result
  end

  def self.get_basic_people_attributes(up_to_1000_ldap_uids)
    result = []
    use_pooled_connection {
      sql = <<-SQL
      select pi.ldap_uid, pi.first_name, pi.last_name, pi.email_address, pi.student_id, pi.affiliations
      from bspace_person_info_vw pi
      where pi.ldap_uid in (#{up_to_1000_ldap_uids.join(', ')})
      SQL
      result = connection.select_all(sql)
    }
    result
  end

  def self.get_reg_status(person_id)
    result = nil
      use_pooled_connection {
      sql = <<-SQL
      select pi.ldap_uid, pi.student_id, reg.reg_status_cd
      from bspace_person_info_vw pi
      left outer join bspace_student_term_vw reg on
        ( reg.ldap_uid = pi.ldap_uid
          and reg.term_yr = #{connection.quote(current_year)}
          and reg.term_cd = #{connection.quote(current_term)}
        )
      where pi.ldap_uid = #{connection.quote(person_id)}
      SQL
      result = connection.select_one(sql)
    }
    if result == nil || result["reg_status_cd"] == nil
      nil
    else
      result
    end
  end

  def self.get_enrolled_students(ccn, term_yr, term_cd)
    result = []
    use_pooled_connection {
      sql = <<-SQL
      select roster.student_ldap_uid ldap_uid, roster.enroll_status,
        person.first_name, person.last_name, person.email_address, person.student_id, person.affiliations
      from bspace_class_roster_vw roster, bspace_person_info_vw person
      where roster.term_yr = #{connection.quote(term_yr)}
        and roster.term_cd = #{connection.quote(term_cd)}
        and roster.course_cntl_num = #{connection.quote(ccn)}
        and roster.student_ldap_uid = person.ldap_uid
        and roster.enroll_status != 'D'
      SQL
      result = connection.select_all(sql)
    }
    result
  end

  def self.get_course_from_section(ccn, term_yr, term_cd)
    result = {}
    use_pooled_connection {
      sql = <<-SQL
      select course_title, dept_name, catalog_id, term_yr, term_cd
      from bspace_course_info_vw
      where term_yr = #{connection.quote(term_yr)}
        and term_cd = #{connection.quote(term_cd)}
        and course_cntl_num = #{connection.quote(ccn)}
      SQL
      result = connection.select_one(sql)
    }
    result
  end

  def self.get_courses_from_sections(term_yr, term_cd, ccns)
    result = {}
    use_pooled_connection {
      sql = <<-SQL
      select distinct course_title, dept_name, catalog_id, term_yr, term_cd
      from bspace_course_info_vw
      where term_yr = #{connection.quote(term_yr)}
        and term_cd = #{connection.quote(term_cd)}
        and course_cntl_num in (#{ccns.collect{|id| connection.quote(id)}.join(', ')})
      SQL
      result = connection.select_all(sql)
    }
    result
  end

  def self.get_sections_from_course(dept_name, catalog_id, term_yr, term_cd)
    result = []
    use_pooled_connection {
      sql = <<-SQL
      select term_yr, term_cd, course_cntl_num, dept_name, catalog_id, primary_secondary_cd, section_num, instruction_format
      from bspace_course_info_vw
      where term_yr = #{connection.quote(term_yr)}
        and term_cd = #{connection.quote(term_cd)}
        and dept_name = #{connection.quote(dept_name)}
        and catalog_id = #{connection.quote(catalog_id)}
        and section_cancel_flag is null
      SQL
      result = connection.select_all(sql)
    }
    result
  end

  # Catalog ID sorting is: "99", "101L", "C103", "C107L", "110", "110L", "C112", "C112L"
  def self.get_enrolled_sections(person_id, terms = nil)
    result = []
    terms_clause = terms_query_clause('r', terms)
    use_pooled_connection {
      sql = <<-SQL
      select c.term_yr, c.term_cd, c.course_cntl_num, r.enroll_status, r.wait_list_seq_num, r.unit, r.pnp_flag,
        c.course_title, c.dept_name, c.catalog_id, c.primary_secondary_cd, c.section_num, c.instruction_format,
        c.catalog_root, c.catalog_prefix, c.catalog_suffix_1, c.catalog_suffix_2, c.enroll_limit
      from bspace_class_roster_vw r
      join bspace_course_info_vw c on (
        c.term_yr = r.term_yr
          and c.term_cd = r.term_cd
          and c.course_cntl_num = r.course_cntl_num )
      where r.student_ldap_uid = #{connection.quote(person_id)}
        #{terms_clause}
      order by c.term_yr desc, c.term_cd desc, c.dept_name,
        c.catalog_root, c.catalog_prefix nulls first, c.catalog_suffix_1 nulls first, c.catalog_suffix_2 nulls first,
        c.primary_secondary_cd, c.instruction_format, c.section_num
      SQL
      result = connection.select_all(sql)
    }
    result
  end

  def self.get_transcript_grades(person_id, terms = nil)
    result = []
    terms_clause = terms_query_clause('t', terms)
    use_pooled_connection {
      sql = <<-SQL
      select t.term_yr, t.term_cd, trim(t.dept_cd) as dept_name, trim(t.course_num) as catalog_id,
        trim(t.grade) as grade, t.unit as transcript_unit
      from calcentral_transcript_vw t where
        t.student_ldap_uid = #{connection.quote(person_id)}
          and t.unit != 0
          #{terms_clause}
      order by t.term_yr desc, t.term_cd desc, dept_name, catalog_id
      SQL
      result = connection.select_all(sql)
    }
    result
  end

  def self.get_instructing_sections(person_id, terms = nil)
    result = []
    terms_clause = terms_query_clause('i', terms)
    use_pooled_connection {
      sql = <<-SQL
      select c.term_yr, c.term_cd, c.course_cntl_num,
        c.course_title, c.dept_name, c.catalog_id, c.primary_secondary_cd, c.section_num, c.instruction_format,
        c.catalog_root, c.catalog_prefix, c.catalog_suffix_1, c.catalog_suffix_2
      from bspace_course_instructor_vw i
      join bspace_course_info_vw c on c.term_yr = i.term_yr and c.term_cd = i.term_cd and c.course_cntl_num = i.course_cntl_num
      where i.instructor_ldap_uid = #{connection.quote(person_id)}
        #{terms_clause}
      order by c.term_yr desc, c.term_cd desc, c.dept_name,
        c.catalog_root, c.catalog_prefix nulls first, c.catalog_suffix_1 nulls first, c.catalog_suffix_2 nulls first,
        c.primary_secondary_cd, c.instruction_format, c.section_num
      SQL
      result = connection.select_all(sql)
    }
    result
  end

  def self.get_section_schedules(term_yr, term_cd, ccn)
    result = []
    use_pooled_connection {
      sql = <<-SQL
        select sched.BUILDING_NAME, sched.ROOM_NUMBER, sched.MEETING_DAYS, sched.MEETING_START_TIME,
        sched.MEETING_START_TIME_AMPM_FLAG, sched.MEETING_END_TIME, sched.MEETING_END_TIME_AMPM_FLAG
        from BSPACE_CLASS_SCHEDULE_VW sched
        where sched.TERM_YR = #{connection.quote(term_yr)}
          and sched.TERM_CD = #{connection.quote(term_cd)}
          and sched.COURSE_CNTL_NUM = #{connection.quote(ccn)}
          and (sched.PRINT_CD is null or sched.PRINT_CD <> 'C')
          and (sched.MULTI_ENTRY_CD is null or sched.MULTI_ENTRY_CD <> 'C')
      SQL
      result = connection.select_all(sql)
    }
    result
  end

  def self.get_section_instructors(term_yr, term_cd, ccn)
    result = []
    use_pooled_connection {
      sql = <<-SQL
        select p.person_name, p.ldap_uid, bci.instructor_func,
          p.first_name, p.last_name, p.email_address, p.student_id, p.affiliations
        from bspace_course_instructor_vw bci
        join bspace_person_info_vw p on p.ldap_uid = bci.instructor_ldap_uid
        where bci.instructor_ldap_uid = p.ldap_uid
          and bci.term_yr = #{connection.quote(term_yr)}
          and bci.term_cd = #{connection.quote(term_cd)}
          and bci.course_cntl_num = #{connection.quote(ccn)}
        order by bci.instructor_func
      SQL
      result = connection.select_all(sql)
    }
    result
  end

  def self.get_photo(ldap_uid)
    result = {}
    use_pooled_connection {
      sql = <<-SQL
        select ph.bytes, ph.photo
        from bspace_student_photo_vw ph
        where ph.student_ldap_uid=#{connection.quote(ldap_uid)}
      SQL
      result = connection.select_one(sql)
    }
    result
  end

  def self.get_student_info(ldap_uid)
    result = {}
    use_pooled_connection {
      sql = <<-SQL
        select s.cum_gpa, s.tot_units, s.first_reg_term_cd, s.first_reg_term_yr,
          s.ug_grad_flag, s.affiliations
        from calcentral_student_info_vw s
        where s.student_ldap_uid=#{connection.quote(ldap_uid)}
      SQL
      result = connection.select_one(sql)
    }
    result
  end



  def self.is_previous_ugrad?(ldap_uid)
    result = {}
    use_pooled_connection {
      # A somewhat expensive query. Use with caution.
      sql = <<-SQL
        select ts.student_ldap_uid from calcentral_transcript_vw ts
        where ts.line_type = 'U'
          and ts.student_ldap_uid = #{connection.quote(ldap_uid)}
      SQL
      result = connection.select_one(sql)
    }
    result.present?
  end

  def self.database_alive?
    is_alive = false
    begin
      use_pooled_connection {
        connection.select_one("select 1 from DUAL")
        is_alive = true
      }
    rescue ActiveRecord::StatementInvalid => exception
      Rails.logger.warn("Oracle server is down: #{exception}")
    end
    is_alive
  end

  def self.is_student?(person_attributes)
    !person_attributes['student_id'].blank? &&
        /STUDENT-TYPE-/.match(person_attributes['affiliations'])
  end

  def self.has_instructor_history?(ldap_uid, instructor_terms = nil)
    result = {}
    instructor_terms_clause = terms_query_clause('r', instructor_terms)
    use_pooled_connection {
      sql = <<-SQL
        select count(r.term_yr) as course_count
        from bspace_course_instructor_vw r
        where r.instructor_ldap_uid = #{connection.quote(ldap_uid)}
          and rownum < 2
          #{instructor_terms_clause}
      SQL
      result = connection.select_one(sql)
    }
    Rails.logger.debug "Instructor #{ldap_uid} history for terms #{instructor_terms} count = #{result}"
    return result["course_count"].to_i > 0
  end

  def self.has_student_history?(ldap_uid, student_terms = nil)
    result = {}
    student_terms_clause = terms_query_clause('r', student_terms)
    use_pooled_connection {
      sql = <<-SQL
        select count(r.term_yr) as course_count
        from bspace_class_roster_vw r
        where r.student_ldap_uid = #{connection.quote(ldap_uid)}
          and rownum < 2
          #{student_terms_clause}
      SQL
      result = connection.select_one(sql)
    }
    Rails.logger.debug "Student #{ldap_uid} history for terms #{student_terms} count = #{result}"
    return result["course_count"].to_i > 0
  end

  def self.terms_query_clause(table, terms)
    if !terms.blank?
      clause = 'and ('
      terms.each_index do |idx|
        clause.concat(' or ') if idx > 0
        clause.concat("(#{table}.term_cd=#{connection.quote(terms[idx].term_cd)} and #{table}.term_yr=#{connection.quote(terms[idx].term_yr)})")
      end
      clause.concat(')')
      clause
    else
      ''
    end
  end

end
