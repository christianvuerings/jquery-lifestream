class CampusData < ActiveRecord::Base
  establish_connection "campusdb"

  def self.get_person_attributes(person_id)
    sql = <<-SQL
		select pi.ldap_uid, pi.ug_grad_flag, pi.first_name, pi.last_name, pi.person_name, pi.email_address, pi.affiliations
		from bspace_person_info_vw pi
		where pi.ldap_uid = #{connection.quote(person_id)}
    SQL
    attrs = connection.select_one(sql)
  end
end
