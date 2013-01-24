class CampusData < ActiveRecord::Base
  establish_connection "campusdb"

  # TODO parameterize current year & term. CLC-951.

  def self.current_year
    2012
  end

  def self.current_term
    'D'
  end

  def self.get_person_attributes(person_id)
    sql = <<-SQL
		select pi.ldap_uid, pi.ug_grad_flag, pi.first_name, pi.last_name, pi.person_name, pi.email_address, pi.affiliations
		from bspace_person_info_vw pi
		where pi.ldap_uid = #{connection.quote(person_id)}
    SQL
    attrs = connection.select_one(sql)
  end

  def self.get_reg_status(person_id)
    sql = <<-SQL
		select pi.ldap_uid, reg.reg_status_cd, reg.on_probation_flag
		from bspace_person_info_vw pi
    left outer join bspace_student_reghist_vw reg on
      ( reg.ldap_uid = pi.ldap_uid
        and reg.term_yr = #{connection.quote(current_year)}
        and reg.term_cd = #{connection.quote(current_term)}
      )
		where pi.ldap_uid = #{connection.quote(person_id)}
    SQL
    attrs = connection.select_one(sql)
  end
end
