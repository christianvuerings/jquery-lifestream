module Oec
  class Queries < CampusOracle::Connection
    include ActiveRecordHelper

    def self.courses_for_codes(term_code, course_codes)
      get_courses(nil, course_codes, term_code)
    end

    def self.courses_for_cntl_nums(term_code, course_cntl_nums)
      get_courses(course_cntl_nums, nil, term_code)
    end

    def self.get_courses(course_cntl_nums = nil, course_codes = nil, term_code)
      course_cntl_nums_clause = course_cntl_nums.present? ? self.query_in_chunks('c.course_cntl_num', course_cntl_nums.split(',')) : ''
      this_depts_clause = course_cntl_nums.present? ? '' : depts_clause('c', course_codes)
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
        #{terms_clause('c', term_code)}
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
    def self.get_secondary_cross_listings(term_code, secondary_ccn_array = [])
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
        #{terms_clause('c', term_code)}
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

    def self.depts_clause(table, course_codes)
      return '' if !course_codes
      subclauses = course_codes.group_by(&:dept_name).map do |dept_name, codes|
        subclause = ''
        if (default_code = codes.find { |code| code.catalog_id.blank? }) && default_code.include_in_oec
          #All catalog IDs are included by default; note explicit exclusions
          excluded_catalog_ids = codes.reject(&:include_in_oec).map { |code| "'#{code.catalog_id}'" }
          subclause << "#{table}.dept_name = '#{dept_name}'"
          if excluded_catalog_ids.any?
            subclause << " and #{table}.catalog_id NOT IN (#{excluded_catalog_ids.join(',')})"
          end
        else
          #No catalog IDs are included by default; note explicit inclusions
          included_catalog_ids = codes.select(&:include_in_oec).map { |code| "'#{code.catalog_id}'" }
          if included_catalog_ids.any?
            subclause << "#{table}.dept_name = '#{dept_name}' and #{table}.catalog_id IN (#{included_catalog_ids.join(',')})"
          end
        end
        subclause
      end
      case subclauses.count
        when 0
          ''
        when 1
          "and (#{subclauses.first})"
        else
          "and (#{subclauses.map { |subclause| "(#{subclause})" }.join(' or ')})"
      end
    end

    def self.terms_clause(table, term_code)
      term_yr, term_cd = term_code.split('-')
      "and #{table}.term_yr = '#{term_yr}' and #{table}.term_cd = '#{term_cd}'"
    end

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
