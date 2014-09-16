module Oec
  class Queries < CampusOracle::Connection
    include ActiveRecordHelper

    def self.get_all_courses(course_cntl_nums = nil)
      result = []
      course_cntl_nums_clause = ''
      this_depts_clause = depts_clause('c', Settings.oec.departments)
      if course_cntl_nums.present?
        course_cntl_nums_clause = self.ccns_in_chunks('c', course_cntl_nums.split(','))
        this_depts_clause = ''
      end

      use_pooled_connection {
        sql = <<-SQL
      select
        distinct c.term_yr, c.term_cd, c.course_cntl_num, p.ldap_uid,
        c.term_yr || '-' || c.term_cd || '-' || lpad(c.course_cntl_num, 5, '0') AS course_id,
        c.dept_name || ' ' || c.catalog_id || ' ' || c.instruction_format || ' ' || c.section_num || ' ' || c.course_title_short AS course_name,
        c.cross_listed_flag,
        (
          select listagg(course_cntl_num, ', ') within group (order by course_cntl_num)
          from calcentral_cross_listing_vw
          where term_yr = c.term_yr and term_cd = c.term_cd and crosslist_hash = x.crosslist_hash
        ) AS cross_listed_name,
        c.dept_name,
        c.catalog_id,
        c.instruction_format,
        c.section_num,
        c.primary_secondary_cd,
        c.course_title_short,
        p.first_name,
        p.last_name,
        p.email_address,
        p.ldap_uid,
        i.instructor_func,
        '23' AS blue_role,
        null AS evaluate,
        null AS evaluation_type,
        null AS modular_course,
        null AS start_date,
        null AS end_date
      from calcentral_course_info_vw c
      left outer join calcentral_cross_listing_vw x ON ( x.term_yr = c.term_yr and x.term_cd = c.term_cd and x.course_cntl_num = c.course_cntl_num )
      left outer join calcentral_course_instr_vw i ON (i.course_cntl_num = c.course_cntl_num AND i.term_yr = c.term_yr AND i.term_cd = c.term_cd)
      left outer join calcentral_person_info_vw p ON (p.ldap_uid = i.instructor_ldap_uid)
      left outer join calcentral_class_roster_vw r ON (r.course_cntl_num = c.course_cntl_num AND r.term_yr = c.term_yr AND r.term_cd = c.term_cd)
      where 1=1 #{terms_query_clause('c', Settings.oec.current_terms_codes)} #{this_depts_clause} #{course_cntl_nums_clause}
        and r.enroll_status != 'D'
        and exists (
          select r.course_cntl_num
          from calcentral_class_roster_vw r
          where r.enroll_status != 'D'
            and r.term_yr = c.term_yr
            and r.term_cd = c.term_cd
            and r.course_cntl_num = c.course_cntl_num
            and rownum < 2
          )
      order by c.course_cntl_num, p.ldap_uid
        SQL
        result = connection.select_all(sql)
      }
      stringify_ints! result
    end

    def self.get_all_students(course_cntl_nums=[])
      result = []
      use_pooled_connection {
        sql = <<-SQL
        select distinct person.first_name, person.last_name,
          person.email_address, person.ldap_uid
        from calcentral_person_info_vw person, calcentral_class_roster_vw r, calcentral_course_info_vw c
        where
          c.section_cancel_flag is null
          #{terms_query_clause('c', Settings.oec.current_terms_codes)}
          #{self.ccns_in_chunks('c', course_cntl_nums)}
          and r.enroll_status != 'D'
          and r.term_yr = c.term_yr
          and r.term_cd = c.term_cd
          and r.course_cntl_num = c.course_cntl_num
          and r.student_ldap_uid = person.ldap_uid
        order by ldap_uid
        SQL
        result = connection.select_all(sql)
      }
      stringify_ints! result
    end

    def self.get_all_course_students(course_cntl_nums=[])
      result = []
      use_pooled_connection {
        sql = <<-SQL
      select distinct r.term_yr || '-' || r.term_cd || '-' || lpad(r.course_cntl_num, 5, '0') AS course_id,
        r.student_ldap_uid AS ldap_uid
      from calcentral_course_info_vw c, calcentral_class_roster_vw r
      where
          c.section_cancel_flag is null
          #{terms_query_clause('c', Settings.oec.current_terms_codes)}
          #{self.ccns_in_chunks('c', course_cntl_nums)}
          and r.enroll_status != 'D'
          and r.term_yr = c.term_yr
          and r.term_cd = c.term_cd
          and r.course_cntl_num = c.course_cntl_num
      order by ldap_uid
        SQL
        result = connection.select_all(sql)
      }
      stringify_ints! result
    end

    private

    # Oracle has a limit of 1000 terms per expression, so do CCN filtering as a series of OR statements with up to
    # 1000 CCNs per chunk.
    def self.ccns_in_chunks(prefix, course_cntl_nums=[])
      slice = 0
      statement = 'and ( '
      course_cntl_nums.each_slice(1000) { |chunk|
        statement += ' or ' if slice > 0
        statement += "#{prefix}.course_cntl_num IN ( #{chunk.join(',')} )"
        slice += 1
      }
      statement += ')'
      statement
    end

  end
end
