class CampusData < ActiveRecord::Base
  establish_connection "campusdb"

  def self.get_person_attributes(person_id)
    sql = <<-SQL
		select pi.ldap_uid, pi.ug_grad_flag, pi.first_name, pi.last_name, pi.person_name, pi.email_address, pi.affiliations,
			sm.major_name, sm.major_title, sm.college_abbr, sm.major_name2, sm.major_title2, sm.college_abbr2,
			sm.major_name3, sm.major_title3, sm.college_abbr3, sm.major_name4, sm.major_title4, sm.college_abbr4
		from bspace_person_info_vw pi
		left join bspace_student_major_vw sm on pi.ldap_uid = sm.ldap_uid
		where pi.ldap_uid = #{connection.quote(person_id)}
    SQL
    attrs = connection.select_one(sql)
  end
end
