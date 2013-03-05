class CampusData < ActiveRecord::Base
  establish_connection "campusdb"

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
    sql = <<-SQL
		select pi.ldap_uid, pi.ug_grad_flag, pi.first_name, pi.last_name,
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
      result[:roles] = {
          :student => result['affiliations'].include?("STUDENT-TYPE-"),
          :faculty => result['affiliations'].include?("EMPLOYEE-TYPE-ACADEMIC"),
          :staff => result['affiliations'].include?("EMPLOYEE-TYPE-STAFF")
      }
    end
    result
  end

  def self.get_reg_status(person_id)
    sql = <<-SQL
		select pi.ldap_uid, reg.reg_status_cd
		from bspace_person_info_vw pi
    left outer join bspace_student_term_vw reg on
      ( reg.ldap_uid = pi.ldap_uid
        and reg.term_yr = #{connection.quote(current_year)}
        and reg.term_cd = #{connection.quote(current_term)}
      )
		where pi.ldap_uid = #{connection.quote(person_id)}
    SQL
    result = connection.select_one(sql)
    if result == nil || result["reg_status_cd"] == nil
      nil
    else
      result
    end
  end

  def self.get_enrolled_students(ccn, term_yr, term_cd)
    sql = <<-SQL
    select roster.student_ldap_uid ldap_uid
		from bspace_class_roster_vw roster
		where roster.term_yr = #{connection.quote(term_yr)}
      and roster.term_cd = #{connection.quote(term_cd)}
      and roster.course_cntl_num = #{connection.quote(ccn)}
    SQL
    connection.select_all(sql)
  end

  def self.get_course(ccn, term_yr, term_cd)
    sql = <<-SQL
    select course_title, dept_name, catalog_id
		from bspace_course_info_vw
		where term_yr = #{connection.quote(term_yr)}
      and term_cd = #{connection.quote(term_cd)}
      and course_cntl_num = #{connection.quote(ccn)}
    SQL
    connection.select_one(sql)
  end

  def self.check_alive
    connection.select_one("select 1 from DUAL")
  end

end
