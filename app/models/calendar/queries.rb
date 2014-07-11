module Calendar
  class Queries < CampusOracle::Connection
    include ActiveRecordHelper

    def self.get_all_courses(users = [])
      # fail safer: don't return results if whitelist is empty
      if users.empty?
        return []
      end
      result = []
      this_depts_clause = depts_clause('c', Settings.class_calendar.departments)
      users_clause = ''
      if users.length > 0
        users_clause = users_in_chunks users
      end
      use_pooled_connection {
        sql = <<-SQL
      select
        c.term_yr, c.term_cd, c.course_cntl_num,
        c.dept_name || ' ' || c.catalog_id || ' ' || c.instruction_format || ' ' || c.section_num AS course_name
      from calcentral_course_info_vw c
      where 1=1 #{terms_query_clause('c', Settings.class_calendar.current_terms_codes)} #{this_depts_clause}
        and exists (
          select r.course_cntl_num
          from calcentral_class_roster_vw r
          where r.enroll_status != 'D'
            and r.term_yr = c.term_yr
            and r.term_cd = c.term_cd
            and r.course_cntl_num = c.course_cntl_num
            #{users_clause}
            and rownum < 2
          )
      order by c.course_cntl_num
        SQL
        result = connection.select_all(sql)
      }
      stringify_ints! result
    end

    def self.get_whitelisted_students_in_course(users = [], term_yr, term_cd, ccn)
      result = []
      users_clause = ''
      if users.length > 0
        users_clause = users_in_chunks users
      end
      use_pooled_connection {
        sql = <<-SQL
          select p.ldap_uid, p.alternateid AS official_bmail_address
          from calcentral_course_info_vw c, calcentral_class_roster_vw r, calcentral_person_info_vw p
          where r.enroll_status != 'D'
            and r.term_yr = c.term_yr
            and r.term_cd = c.term_cd
            and r.course_cntl_num = c.course_cntl_num
            and r.student_ldap_uid = p.ldap_uid
            and c.term_yr = #{term_yr.to_i}
            and c.term_cd = #{connection.quote(term_cd)}
            and c.course_cntl_num = #{ccn.to_i}
            #{users_clause}
          order by p.ldap_uid
        SQL
        result = connection.select_all(sql)
      }
      stringify_ints! result
    end

    private

    # Oracle has a limit of 1000 terms per expression, so do CCN filtering as a series of OR statements with up to
    # 1000 user ids per chunk.
    def self.users_in_chunks(users=[])
      slice = 0
      statement = 'and ( '
      users.each_slice(1000) { |chunk|
        uids = chunk.map &:uid
        statement += ' or ' if slice > 0
        statement += "r.student_ldap_uid IN ( #{uids.join(',')} )"
        slice += 1
      }
      statement += ')'
      statement
    end

  end
end
