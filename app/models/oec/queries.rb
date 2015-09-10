module Oec
  class Queries < CampusOracle::Connection
    include ActiveRecordHelper

    def self.courses_for_codes(term_code, course_codes, import_all = false)
      return [] unless (filter = depts_clause('c', course_codes, import_all))
      get_courses(term_code, filter)
    end

    def self.courses_for_cntl_nums(term_code, course_cntl_nums)
      return [] unless (filter = ccns_clause('c', course_cntl_nums))
      get_courses(term_code, filter)
    end

    def self.get_courses(term_code, filter_clause)
      term_yr, term_cd = term_code.split('-')
      result = []
      use_pooled_connection {
        sql = <<-SQL
      select distinct c.term_yr, c.term_cd, c.course_cntl_num, p.ldap_uid,
        c.term_yr || '-' || c.term_cd || '-' || lpad(c.course_cntl_num, 5, '0') AS course_id,
        c.dept_name || ' ' || c.catalog_id || ' ' || c.instruction_format || ' ' || c.section_num || ' ' || c.course_title_short AS course_name,
        c.cross_listed_flag,
        c.dept_name,
        c.catalog_id,
        c.instruction_format,
        c.section_num,
        c.primary_secondary_cd,
        c.course_title_short,
        CASE WHEN p.student_id IS NULL THEN 'UID:' || p.ldap_uid ELSE '' || p.student_id END AS sis_id,
        p.first_name,
        p.last_name,
        p.email_address,
        p.affiliations,
        i.instructor_func,
        (
          select count(*)
          from calcentral_class_roster_vw r
          where r.enroll_status != 'D'
            and #{columns_are_equal('r', 'c', 'term_yr', 'term_cd', 'course_cntl_num')}
            and rownum < 2
        ) as enrollment_count,
        '23' AS blue_role,
        (
          select listagg(lpad(course_cntl_num, 5, '0'), ',') within group (order by course_cntl_num)
          from calcentral_cross_listing_vw
          where term_yr = c.term_yr and term_cd = c.term_cd and crosslist_hash = x.crosslist_hash
        ) AS cross_listed_ccns,
        (
          select listagg(lpad(course_cntl_num, 5, '0'), ',') within group (order by course_cntl_num)
          from calcentral_class_schedule_vw l
          where #{not_null('s', 'building_name', 'room_number', 'meeting_days', 'meeting_start_time')}
            and #{columns_are_equal('l', 'c', 'term_yr', 'term_cd')}
            and #{columns_are_equal('l', 's', 'building_name', 'room_number', 'meeting_days', 'meeting_start_time', 'meeting_start_time_ampm_flag', 'meeting_end_time', 'meeting_end_time_ampm_flag')}
            having count(*) > 1
        ) AS co_scheduled_ccns
      from calcentral_course_info_vw c
      left outer join calcentral_cross_listing_vw x ON (#{columns_are_equal('c', 'x', 'term_yr', 'term_cd', 'course_cntl_num')})
      left outer join calcentral_class_schedule_vw s ON (
        #{columns_are_equal('c', 's', 'term_yr', 'term_cd', 'course_cntl_num')}
        and #{not_null('s', 'building_name', 'room_number', 'meeting_days', 'meeting_start_time')})
      left outer join calcentral_course_instr_vw i ON (#{columns_are_equal('c', 'i', 'term_yr', 'term_cd', 'course_cntl_num')})
      left outer join calcentral_person_info_vw p ON (p.ldap_uid = i.instructor_ldap_uid)
      where c.term_yr = '#{term_yr}' and c.term_cd = '#{term_cd}'
        and #{filter_clause}
      order by c.catalog_id, c.course_cntl_num, p.ldap_uid
        SQL
        result = connection.select_all(sql)
      }
      stringify_ints! result
    end

    def self.depts_clause(table, course_codes, import_all)
      return if course_codes.blank?
      subclauses = course_codes.group_by(&:dept_name).map do |dept_name, codes|
        subclause = ''
        if (default_code = codes.find { |code| code.catalog_id.blank? }) && (default_code.include_in_oec || import_all)
          #All catalog IDs are included by default; note explicit exclusions
          excluded_catalog_ids = codes.reject(&:include_in_oec).map { |code| "'#{code.catalog_id}'" }
          subclause << "#{table}.dept_name = '#{dept_name}'"
          if !import_all && excluded_catalog_ids.any?
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
      subclauses.reject! &:blank?
      case subclauses.count
        when 0
          nil
        when 1
          "(#{subclauses.first})"
        else
          "(#{subclauses.map { |subclause| "(#{subclause})" }.join(' or ')})"
      end
    end

    # Oracle has limit of 1000 terms per expression so we filter using a series of OR statements, when necessary.
    def self.ccns_clause(table, ccns)
      return if ccns.blank?
      subclauses = ccns.each_slice(1000).map { |chunk| "#{table}.course_cntl_num IN (#{chunk.join(',')})" }
      "(#{subclauses.join(' or ')})"
    end

    def self.columns_are_equal(table1, table2, *columns)
      columns.map { |column| "#{table1}.#{column} = #{table2}.#{column}" }.join(' and ')
    end

    def self.not_null(table, *columns)
      columns.map { |column| "#{table}.#{column} IS NOT NULL" }.join(' and ')
    end
  end
end
