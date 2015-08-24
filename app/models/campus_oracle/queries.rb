module CampusOracle
  class Queries < Connection
    include ActiveRecordHelper

    def self.get_person_attributes(person_id)
      result = {}
      use_pooled_connection {
        log_access(connection, connection_handler, name)
        sql = <<-SQL
      select pi.ldap_uid, pi.student_id, pi.ug_grad_flag, trim(pi.first_name) as first_name, trim(pi.last_name) as last_name,
        pi.person_name, pi.email_address, pi.affiliations,
        reg.reg_status_cd, reg.educ_level, reg.admin_cancel_flag, reg.acad_blk_flag, reg.admin_blk_flag,
        reg.fin_blk_flag, reg.reg_blk_flag, reg.tot_enroll_unit, reg.cal_residency_flag, reg.reg_special_pgm_cd
      from calcentral_person_info_vw pi
      left outer join calcentral_student_term_vw reg on
        reg.ldap_uid = pi.ldap_uid
      where pi.ldap_uid = #{person_id.to_i}
      order by reg.term_yr desc, reg.term_cd desc
        SQL
        result = connection.select_one(sql)
      }
      stringify_ints!(result, ["tot_enroll_unit"])
    end

    def self.get_basic_people_attributes(up_to_1000_ldap_uids)
      result = []
      use_pooled_connection {
        sql = <<-SQL
        select pi.ldap_uid, trim(pi.first_name) as first_name, trim(pi.last_name) as last_name, pi.email_address, pi.student_id, pi.affiliations
        from calcentral_person_info_vw pi
        where pi.ldap_uid in (#{up_to_1000_ldap_uids.collect { |id| id.to_i }.join(', ')})
        SQL
        result = connection.select_all(sql)
      }
      stringify_ints! result
    end

    def self.get_all_active_people_uids
      uids = []
      use_pooled_connection {
        sql = <<-SQL
        select pi.ldap_uid
        from calcentral_person_info_vw pi
        where (affiliations LIKE '%-TYPE-%')
        SQL
        uids = connection.select_all(sql)
      }
      stringify_ints! uids
      uids.collect {|uid| uid['ldap_uid'] }
    end

    def self.find_people_by_name(name_search_string, limit = 0)
      raise ArgumentError, "Search text argument must be a string" if name_search_string.class != String
      raise ArgumentError, "Limit argument must be a Fixnum" if limit.class != Fixnum
      limit_clause = (limit > 0) ? "where rownum <= #{limit}" : ""
      search_text_array = name_search_string.split(',')
      search_text_array.collect! { |e| e.strip }
      clean_search_string = connection.quote_string(search_text_array.join(','))
      result = []
      use_pooled_connection {
        sql = <<-SQL
        select outr.*
        from (
          select  pi.ldap_uid,
                  trim(pi.first_name) as first_name,
                  trim(pi.last_name) as last_name,
                  pi.email_address,
                  pi.student_id,
                  pi.affiliations,
                  row_number() over(order by 1) row_number,
                  count(*) over() result_count
          from calcentral_person_info_vw pi
          where lower( concat(concat(trim(pi.last_name), ','), trim(pi.first_name)) ) like '#{clean_search_string.downcase}%'
          order by trim(pi.last_name)
        ) outr #{limit_clause}
        SQL
        result = connection.select_all(sql)
      }
      stringify_ints! result
    end

    def self.find_people_by_email(email_search_string, limit = 0)
      raise ArgumentError, "Search text argument must be a string" if email_search_string.class != String
      raise ArgumentError, "Limit argument must be a Fixnum" if limit.class != Fixnum
      limit_clause = (limit > 0) ? "where rownum <= #{limit}" : ""
      clean_search_string = connection.quote_string(email_search_string)
      result = []
      use_pooled_connection {
        sql = <<-SQL
        select outr.*
        from (
          select  pi.ldap_uid,
                  trim(pi.first_name) as first_name,
                  trim(pi.last_name) as last_name,
                  pi.email_address,
                  pi.student_id,
                  pi.affiliations,
                  row_number() over(order by 1) row_number,
                  count(*) over() result_count
          from calcentral_person_info_vw pi
          where lower(pi.email_address) like '%#{clean_search_string.downcase}%'
          order by trim(pi.last_name)
        ) outr #{limit_clause}
        SQL
        result = connection.select_all(sql)
      }
      stringify_ints! result
    end

    def self.find_people_by_student_id(student_id_string)
      raise ArgumentError, "Argument must be a string" if student_id_string.class != String
      raise ArgumentError, "Argument is not an integer string" unless is_integer_string?(student_id_string)
      result = []
      use_pooled_connection {
        sql = <<-SQL
      select pi.ldap_uid, trim(pi.first_name) as first_name, trim(pi.last_name) as last_name, pi.email_address, pi.student_id, pi.affiliations, 1.0 row_number, 1.0 result_count
      from calcentral_person_info_vw pi
      where pi.student_id = #{student_id_string}
      and rownum <= 1
        SQL
        result = connection.select_all(sql)
      }
      stringify_ints! result
    end

    def self.find_people_by_uid(user_id_string)
      raise ArgumentError, "Argument must be a string" if user_id_string.class != String
      raise ArgumentError, "Argument is not an integer string" unless is_integer_string?(user_id_string)
      result = []
      use_pooled_connection {
        sql = <<-SQL
      select pi.ldap_uid, trim(pi.first_name) as first_name, trim(pi.last_name) as last_name, pi.email_address, pi.student_id, pi.affiliations, 1.0 row_number, 1.0 result_count
      from calcentral_person_info_vw pi
      where pi.ldap_uid = #{user_id_string}
      and rownum <= 1
        SQL
        result = connection.select_all(sql)
      }
      stringify_ints! result
    end

    def self.is_integer_string?(string)
      raise ArgumentError, "Argument must be a string" if string.class != String
      string.to_i.to_s == string
    end

    def self.get_reg_status(person_id)
      result = nil
      use_pooled_connection {
        # To date, the student academic status view has always contained data for only one term.
        # The "order by" clause is included in case that changes without warning.
        sql = <<-SQL
      select pi.ldap_uid, pi.student_id, reg.reg_status_cd
      from calcentral_person_info_vw pi
      left outer join calcentral_student_term_vw reg on
        reg.ldap_uid = pi.ldap_uid
      where pi.ldap_uid = #{person_id.to_i}
      order by reg.term_yr desc, reg.term_cd desc
        SQL
        result = connection.select_one(sql)
      }
      if result == nil || result["reg_status_cd"] == nil
        nil
      else
        stringify_ints! result
      end
    end

    def self.get_enrolled_students(ccn, term_yr, term_cd)
      result = []
      use_pooled_connection {
        sql = <<-SQL
      select roster.student_ldap_uid ldap_uid, roster.enroll_status, trim(roster.pnp_flag) as pnp_flag,
        trim(person.first_name) as first_name, trim(person.last_name) as last_name, person.student_email_address, person.student_id, person.affiliations,
        ph.bytes photo_bytes
      from calcentral_class_roster_vw roster, calcentral_student_info_vw person
      left join  calcentral_student_photo_vw ph
        on ph.student_ldap_uid = person.student_ldap_uid
      where roster.term_yr = #{term_yr.to_i}
        and roster.term_cd = #{connection.quote(term_cd)}
        and roster.course_cntl_num = #{ccn.to_i}
        and roster.student_ldap_uid = person.student_ldap_uid
        and roster.enroll_status != 'D'
        SQL
        result = connection.select_all(sql)
      }
      stringify_ints! result
    end

    def self.get_course_from_section(ccn, term_yr, term_cd)
      result = {}
      use_pooled_connection {
        sql = <<-SQL
      select course_title, course_title_short, dept_name, catalog_id, term_yr, term_cd
      from calcentral_course_info_vw
      where term_yr = #{term_yr.to_i}
        and term_cd = #{connection.quote(term_cd)}
        and course_cntl_num = #{ccn.to_i}
        SQL
        result = connection.select_one(sql)
      }
      stringify_ints! result
    end

    def self.get_sections_from_ccns(term_yr, term_cd, ccns)
      result = {}
      use_pooled_connection {
        sql = <<-SQL
      select course_title, course_title_short, dept_name, catalog_id, term_yr, term_cd, course_cntl_num, primary_secondary_cd, section_num, instruction_format,
        catalog_root, catalog_prefix, catalog_suffix_1, catalog_suffix_2
      from calcentral_course_info_vw
      where term_yr = #{term_yr.to_i}
        and term_cd = #{connection.quote(term_cd)}
        and course_cntl_num in (#{ccns.collect { |id| id.to_i }.join(', ')})
      order by dept_name, catalog_root, catalog_prefix nulls first, catalog_suffix_1 nulls first, catalog_suffix_2 nulls first,
        primary_secondary_cd, instruction_format, section_num
        SQL
        result = connection.select_all(sql)
      }
      stringify_ints! result
    end

    # Catalog ID sorting is: "99", "101L", "C103", "C107L", "110", "110L", "C112", "C112L"
    def self.get_enrolled_sections(person_id, terms = nil)
      result = []
      terms_clause = terms_query_clause('r', terms)
      use_pooled_connection {
        sql = <<-SQL
      select d.dept_description, c.term_yr, c.term_cd, c.course_cntl_num, r.enroll_status, r.wait_list_seq_num, r.unit, r.pnp_flag, r.grade,
        c.course_title, c.course_title_short, c.dept_name, c.catalog_id, c.primary_secondary_cd, c.section_num, c.instruction_format,
        c.catalog_root, c.catalog_prefix, c.catalog_suffix_1, c.catalog_suffix_2, c.enroll_limit, c.cred_cd, c.course_option
      from calcentral_class_roster_vw r
      join calcentral_course_info_vw c on (
        c.term_yr = r.term_yr
          and c.term_cd = r.term_cd
          and c.course_cntl_num = r.course_cntl_num )
      join calcentral_dept_vw d on (
        d.dept_name = c.dept_name)
      where r.student_ldap_uid = #{person_id.to_i}
        and c.section_cancel_flag is null
        #{terms_clause}
      order by c.term_yr desc, c.term_cd desc, c.dept_name,
        c.catalog_root, c.catalog_prefix nulls first, c.catalog_suffix_1 nulls first, c.catalog_suffix_2 nulls first,
        c.primary_secondary_cd, c.instruction_format, c.section_num
        SQL
        result = connection.select_all(sql)
      }
      stringify_ints! result
    end

    def self.get_transcript_grades(person_id, terms = nil)
      result = []
      terms_clause = terms_query_clause('t', terms)
      use_pooled_connection {
        sql = <<-SQL
      select t.term_yr, t.term_cd, trim(t.dept_cd) as dept_name, trim(t.course_num) as catalog_id,
        trim(t.grade) as grade, t.unit as transcript_unit, t.line_type, trim(t.memo_or_title) as memo_or_title
      from calcentral_transcript_vw t where
        t.student_ldap_uid = #{person_id.to_i}
          #{terms_clause}
      order by t.term_yr desc, t.term_cd desc, t.line_num
        SQL
        result = connection.select_all(sql)
      }
      stringify_ints! result
    end

    def self.get_instructing_sections(person_id, terms = nil)
      result = []
      terms_clause = terms_query_clause('i', terms)
      use_pooled_connection {
        sql = <<-SQL
      select d.dept_description, c.term_yr, c.term_cd, c.course_cntl_num, c.course_option,
        c.course_title, c.course_title_short, c.dept_name, c.catalog_id, c.primary_secondary_cd, c.section_num, c.instruction_format,
        c.catalog_root, c.catalog_prefix, c.catalog_suffix_1, c.catalog_suffix_2, c.cross_listed_flag
      from calcentral_course_instr_vw i
      join calcentral_course_info_vw c on c.term_yr = i.term_yr and c.term_cd = i.term_cd and c.course_cntl_num = i.course_cntl_num
      join calcentral_dept_vw d on (
        d.dept_name = c.dept_name)
      where i.instructor_ldap_uid = #{person_id.to_i}
        and c.section_cancel_flag is null
        #{terms_clause}
      order by c.term_yr desc, c.term_cd desc, c.dept_name,
        c.catalog_root, c.catalog_prefix nulls first, c.catalog_suffix_1 nulls first, c.catalog_suffix_2 nulls first,
        c.primary_secondary_cd, c.instruction_format, c.section_num
        SQL
        result = connection.select_all(sql)
      }
      stringify_ints! result
    end

    def self.get_cross_listings(term_yr, term_cd, ccns)
      result = {}
      query_result = []
      use_pooled_connection {
        sql = <<-SQL
      select cl.course_cntl_num, cl.crosslist_hash
      from calcentral_cross_listing_vw cl where cl.term_yr = #{term_yr.to_i} and cl.term_cd = #{connection.quote(term_cd)} and
        cl.course_cntl_num in (#{ccns.collect { |id| id.to_i }.join(', ')})
        SQL
        query_result = connection.select_all(sql)
      }
      query_result.each do |row|
        result[row['course_cntl_num'].to_i] = row['crosslist_hash'].to_i if row['crosslist_hash'].present?
      end
      result
    end

    def self.get_course_secondary_sections(term_yr, term_cd, department, catalog_id)
      get_course_sections(term_yr, term_cd, department, catalog_id, true)
    end

    def self.get_all_course_sections(term_yr, term_cd, department, catalog_id)
      get_course_sections(term_yr, term_cd, department, catalog_id, false)
    end

    def self.get_section_schedules(term_yr, term_cd, ccn)
      result = []
      use_pooled_connection {
        sql = <<-SQL
        select sched.BUILDING_NAME, sched.ROOM_NUMBER, sched.MEETING_DAYS, sched.MEETING_START_TIME,
        sched.MEETING_START_TIME_AMPM_FLAG, sched.MEETING_END_TIME, sched.MEETING_END_TIME_AMPM_FLAG,
        sched.MULTI_ENTRY_CD, sched.COURSE_CNTL_NUM, sched.PRINT_CD
        from CALCENTRAL_CLASS_SCHEDULE_VW sched
        where sched.TERM_YR = #{term_yr.to_i}
          and sched.BUILDING_NAME is NOT NULL
          and sched.TERM_CD = #{connection.quote(term_cd)}
          and sched.COURSE_CNTL_NUM = #{ccn.to_i}
        order by sched.PRINT_CD asc nulls last
        SQL
        result = connection.select_all(sql)
      }
      result = filter_multi_entry_codes result
      stringify_ints! result
    end

    def self.get_section_instructors(term_yr, term_cd, ccn)
      result = []
      use_pooled_connection {
        sql = <<-SQL
        select p.person_name, p.ldap_uid, bci.instructor_func,
          trim(p.first_name) as first_name, trim(p.last_name) as last_name, p.email_address, p.student_id, p.affiliations
        from calcentral_course_instr_vw bci
        join calcentral_person_info_vw p on p.ldap_uid = bci.instructor_ldap_uid
        where bci.instructor_ldap_uid = p.ldap_uid
          and bci.term_yr = #{term_yr.to_i}
          and bci.term_cd = #{connection.quote(term_cd)}
          and bci.course_cntl_num = #{ccn.to_i}
        order by bci.instructor_func
        SQL
        result = connection.select_all(sql)
      }
      stringify_ints! result
    end

    def self.get_photo(ldap_uid)
      result = {}
      use_pooled_connection {
        sql = <<-SQL
        select ph.bytes, ph.photo
        from calcentral_student_photo_vw ph
        where ph.student_ldap_uid=#{ldap_uid.to_i}
        SQL
        result = connection.select_one(sql)
      }
      stringify_ints! result
    end

    def self.get_student_info(ldap_uid)
      result = {}
      use_pooled_connection {
        sql = <<-SQL
        select s.cum_gpa, s.tot_units, s.lgr_tot_attempt_unit, s.first_reg_term_cd, s.first_reg_term_yr,
          s.ug_grad_flag, s.affiliations
        from calcentral_student_info_vw s
        where s.student_ldap_uid=#{ldap_uid.to_i}
        SQL
        result = connection.select_one(sql)
      }
      stringify_ints! result
    end

    def self.is_previous_ugrad?(ldap_uid)
      result = {}
      use_pooled_connection {
        sql = <<-SQL
        select ts.student_ldap_uid from calcentral_transcript_vw ts
        where ts.line_type = 'U'
          and ts.student_ldap_uid = #{ldap_uid.to_i}
          and rownum < 2
        SQL
        result = connection.select_one(sql)
      }
      result.present?
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

    def self.has_instructor_history?(ldap_uid, instructor_terms = nil)
      result = {}
      instructor_terms_clause = terms_query_clause('r', instructor_terms)
      use_pooled_connection {
        sql = <<-SQL
        select count(r.term_yr) as course_count
        from calcentral_course_instr_vw r
        where r.instructor_ldap_uid = #{ldap_uid.to_i}
          and rownum < 2
          #{instructor_terms_clause}
        SQL
        result = connection.select_one(sql)
      }
      Rails.logger.debug "Instructor #{ldap_uid} history for terms #{instructor_terms} count = #{result}"
      return result["course_count"].to_i > 0
    end

    def self.has_student_history?(ldap_uid, student_terms = nil)
      result = {}
      student_terms_clause = terms_query_clause('r', student_terms)
      use_pooled_connection {
        sql = <<-SQL
        select count(r.term_yr) as course_count
        from calcentral_class_roster_vw r
        where r.student_ldap_uid = #{ldap_uid.to_i}
          and rownum < 2
          #{student_terms_clause}
        SQL
        result = connection.select_one(sql)
      }
      Rails.logger.debug "Student #{ldap_uid} history for terms #{student_terms} count = #{result}"
      return result["course_count"].to_i > 0
    end

    def self.terms
      result = []
      use_pooled_connection {
        sql = <<-SQL
        select term_century || term_yr as term_yr, term_cd, term_status, trim(term_status_desc) as term_status_desc,
          trim(term_name) as term_name, current_tb_term_flag, term_start_date, term_end_date
        from calcentral_term_info_vw
        order by term_start_date desc
        SQL
        result = connection.select_all(sql)
      }
      result
    end

    private

    def self.get_course_sections(term_yr, term_cd, department, catalog_id, only_secondary_sections)
      result = []
      section_type_condition = only_secondary_sections ? ' and c.primary_secondary_cd != \'P\' ' : ''
      use_pooled_connection {
        sql = <<-SQL
      select c.term_yr, c.term_cd, c.course_cntl_num,
        c.dept_name, c.catalog_id, c.section_num, c.instruction_format,
        c.catalog_root, c.catalog_prefix, c.catalog_suffix_1, c.catalog_suffix_2
      from calcentral_course_info_vw c where c.term_yr = #{term_yr.to_i} and c.term_cd = #{connection.quote(term_cd)} and
        c.dept_name = #{connection.quote(department)} and c.catalog_id = #{connection.quote(catalog_id)} and
        c.section_cancel_flag is null
        #{section_type_condition}
      order by c.term_yr desc, c.term_cd desc, c.dept_name,
        c.catalog_root, c.catalog_prefix nulls first, c.catalog_suffix_1 nulls first, c.catalog_suffix_2 nulls first,
        c.instruction_format, c.section_num
        SQL
        result = connection.select_all(sql)
      }
      stringify_ints! result
    end

  end
end
