module Oec
  class Queries < CampusOracle::Connection
    include ActiveRecordHelper

    def self.get_courses(course_cntl_nums = nil, dept = nil)
      course_cntl_nums_clause = course_cntl_nums.present? ? self.query_in_chunks('c.course_cntl_num', course_cntl_nums.split(',')) : ''
      this_depts_clause = course_cntl_nums.present? ? '' : depts_clause('c', [ dept ])
      result = []
      use_pooled_connection {
        sql = <<-SQL
      select
        #{self.get_all_courses_select_list},
        (
          select listagg(course_cntl_num, ', ') within group (order by course_cntl_num)
          from calcentral_cross_listing_vw
          where term_yr = c.term_yr and term_cd = c.term_cd and crosslist_hash = x.crosslist_hash
        ) AS cross_listed_name
      from calcentral_course_info_vw c
      left outer join calcentral_cross_listing_vw x ON ( x.term_yr = c.term_yr and x.term_cd = c.term_cd and x.course_cntl_num = c.course_cntl_num )
      left outer join calcentral_course_instr_vw i ON (i.course_cntl_num = c.course_cntl_num AND i.term_yr = c.term_yr AND i.term_cd = c.term_cd)
      left outer join calcentral_person_info_vw p ON (p.ldap_uid = i.instructor_ldap_uid)
      where 1=1
        #{terms_query_clause('c', Settings.oec.current_terms_codes)}
        #{this_depts_clause}
        #{course_cntl_nums_clause}
      order by c.catalog_id, c.course_cntl_num, p.ldap_uid
        SQL
        result = connection.select_all(sql)
      }
      stringify_ints! result
    end

    # This SQL query defines informally cross-listed sections as secondary sections which share a meeting time and place
    # and which include enrolled students.
    def self.get_secondary_cross_listings(secondary_ccn_array = [])
      result = []
      use_pooled_connection {
        sql = <<-SQL
      select
        #{self.get_all_courses_select_list},
        null AS cross_listed_name
      from calcentral_course_info_vw c
      left outer join calcentral_course_instr_vw i ON (i.course_cntl_num = c.course_cntl_num AND i.term_yr = c.term_yr AND i.term_cd = c.term_cd)
      left outer join calcentral_person_info_vw p ON (p.ldap_uid = i.instructor_ldap_uid)
      left outer join calcentral_class_schedule_vw s ON (s.course_cntl_num = c.course_cntl_num AND s.term_yr = c.term_yr AND s.term_cd = c.term_cd)
      where 1=1
        #{terms_query_clause('c', Settings.oec.current_terms_codes)}
        and c.primary_secondary_cd = 'S'
        and s.building_name IS NOT NULL and s.room_number IS NOT NULL and s.meeting_days IS NOT NULL and s.meeting_start_time IS NOT NULL
        and #{self.get_location_time_uid_ref('s')} IN
        (
          select #{self.get_location_time_uid_ref('l')}
          from calcentral_class_schedule_vw l
          where
            l.term_yr = c.term_yr
            and l.term_cd = c.term_cd
            #{self.query_in_chunks('l.course_cntl_num', secondary_ccn_array) if secondary_ccn_array.present?}
            #{'and 0=1' unless secondary_ccn_array.present?}
        )
      order by c.catalog_id, c.course_cntl_num, p.ldap_uid
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
          person.email_address, person.ldap_uid,
          CASE WHEN person.student_id IS NULL
                 THEN 'UID:' || person.ldap_uid
                 ELSE '' || person.student_id
          END AS sis_id
        from calcentral_class_roster_vw r
        left outer join calcentral_person_info_vw person ON (person.ldap_uid = r.student_ldap_uid)
        left outer join calcentral_course_info_vw c ON (r.course_cntl_num = c.course_cntl_num)
        where
          c.section_cancel_flag is null
          #{terms_query_clause('c', Settings.oec.current_terms_codes)}
          #{self.query_in_chunks('c.course_cntl_num', course_cntl_nums)}
          and (r.enroll_status = 'E' OR r.enroll_status = 'C')
          and r.term_yr = c.term_yr
          and r.term_cd = c.term_cd
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
      from calcentral_class_roster_vw r
      left outer join calcentral_course_info_vw c ON (c.course_cntl_num = r.course_cntl_num)
      where
          c.section_cancel_flag is null
          #{terms_query_clause('c', Settings.oec.current_terms_codes)}
          #{self.query_in_chunks('c.course_cntl_num', course_cntl_nums)}
          and (r.enroll_status = 'E' OR r.enroll_status = 'C')
          and r.term_yr = c.term_yr
          and r.term_cd = c.term_cd
      order by ldap_uid
        SQL
        result = connection.select_all(sql)
      }
      stringify_ints! result
    end

    private

    # Shared SQL fragment
    def self.get_all_courses_select_list
      <<-eos
        distinct c.term_yr, c.term_cd, c.course_cntl_num, p.ldap_uid,
        c.term_yr || '-' || c.term_cd || '-' || lpad(c.course_cntl_num, 5, '0') AS course_id,
        c.dept_name || ' ' || c.catalog_id || ' ' || c.instruction_format || ' ' || c.section_num || ' ' || c.course_title_short AS course_name,
        c.cross_listed_flag,
        c.dept_name,
        c.catalog_id,
        c.instruction_format,
        c.section_num,
        c.primary_secondary_cd,
        c.course_title_short,
        CASE WHEN p.student_id IS NULL
               THEN 'UID:' || p.ldap_uid
               ELSE '' || p.student_id
        END AS sis_id,
        p.first_name,
        p.last_name,
        p.email_address,
        i.instructor_func,
        (
          select count(*)
          from calcentral_class_roster_vw r
          where r.enroll_status != 'D'
            and r.term_yr = c.term_yr
            and r.term_cd = c.term_cd
            and r.course_cntl_num = c.course_cntl_num
            and rownum < 2
        ) as enrollment_count,
        '23' AS blue_role,
        null AS evaluate,
        null AS dept_form,
        null AS evaluation_type,
        null AS modular_course,
        null AS start_date,
        null AS end_date
      eos
    end

    # Oracle has limit of 1000 terms per expression so we filter using a series of OR statements, when necessary.
    def self.query_in_chunks(column_ref, values=[])
      slice = 0
      statement = 'and ( '
      values.each_slice(1000) { |chunk|
        statement += ' or ' if slice > 0
        statement += "#{column_ref} IN ( #{chunk.join(',')} )"
        slice += 1
      }
      statement += ')'
      statement
    end

    def self.get_location_time_uid_ref(prefix)
      "#{prefix}.building_name || #{prefix}.room_number || #{prefix}.meeting_days || #{prefix}.meeting_start_time || #{prefix}.meeting_start_time_ampm_flag || #{prefix}.meeting_end_time || #{prefix}.meeting_end_time_ampm_flag"
    end

  end
end
