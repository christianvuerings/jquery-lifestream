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

  def self.reg_block_translator
    @reg_block_translator ||= RegBlockTranslator.new
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
      result[:reg_block] = self.reg_block_translator.translate(result["acad_blk_flag"], result["admin_blk_flag"], result["fin_blk_flag"], result["reg_blk_flag"])
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
      select roster.student_ldap_uid ldap_uid
      from bspace_class_roster_vw roster
      where roster.term_yr = #{connection.quote(term_yr)}
        and roster.term_cd = #{connection.quote(term_cd)}
        and roster.course_cntl_num = #{connection.quote(ccn)}
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
  def self.get_enrolled_sections(person_id, term_yr, term_cd)
    result = []
    use_pooled_connection {
      sql = <<-SQL
      select r.term_yr, r.term_cd, r.course_cntl_num, r.enroll_status, r.wait_list_seq_num,
        c.course_title, c.dept_name, c.catalog_id, c.primary_secondary_cd, c.section_num, c.instruction_format,
        c.catalog_root, c.catalog_prefix, c.catalog_suffix_1, c.catalog_suffix_2
      from bspace_class_roster_vw r
      join bspace_course_info_vw c on c.term_yr = r.term_yr and c.term_cd = r.term_cd and c.course_cntl_num = r.course_cntl_num
      where r.student_ldap_uid = #{connection.quote(person_id)}
        and r.term_yr = #{connection.quote(term_yr)}
        and r.term_cd = #{connection.quote(term_cd)}
      order by r.term_yr, r.term_cd, c.dept_name,
        c.catalog_root, c.catalog_prefix nulls first, c.catalog_suffix_1 nulls first, c.catalog_suffix_2 nulls first,
        c.primary_secondary_cd, c.instruction_format, c.section_num
      SQL
      result = connection.select_all(sql)
    }
    result
  end

  def self.get_instructing_sections(person_id, term_yr, term_cd)
    result = []
    use_pooled_connection {
      sql = <<-SQL
      select c.term_yr, c.term_cd, c.course_cntl_num,
        c.course_title, c.dept_name, c.catalog_id, c.primary_secondary_cd, c.section_num, c.instruction_format,
        c.catalog_root, c.catalog_prefix, c.catalog_suffix_1, c.catalog_suffix_2
      from bspace_course_instructor_vw i
      join bspace_course_info_vw c on c.term_yr = i.term_yr and c.term_cd = i.term_cd and c.course_cntl_num = i.course_cntl_num
      where i.instructor_ldap_uid = #{connection.quote(person_id)}
        and i.term_yr = #{connection.quote(term_yr)}
        and i.term_cd = #{connection.quote(term_cd)}
      order by c.term_yr, c.term_cd, c.dept_name,
        c.catalog_root, c.catalog_prefix nulls first, c.catalog_suffix_1 nulls first, c.catalog_suffix_2 nulls first,
        c.primary_secondary_cd, c.instruction_format, c.section_num
      SQL
      result = connection.select_all(sql)
    }
    result
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

end
