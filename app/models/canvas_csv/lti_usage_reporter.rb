module CanvasCsv
  class LtiUsageReporter < Base

    attr_accessor :external_tool_instance_id_to_url, :tool_url_to_summary, :course_to_visible_tools, :summary_report, :courses_report

    # Basic enabled-out-of-the-box course apps do not need to be included in the detailed course tools report.
    COMMONPLACE_APPS = Regexp.new '/canvas/embedded/(course_add_user|course_grade_export|course_manage_official_sections|rosters)$'

    def initialize(sis_term_id)
      super()

      # The report can be run against any term, but because the configurations of courses in past terms
      # will be changed as changes are made to account-level external_tools configurations, new
      # reports will become increasingly inaccurate. Reports made at the end of a semester should
      # be archived rather than regenerated.
      @sis_term_id = sis_term_id

      # Tools which are not configured at the top account may have more than one Canvas ID and more than one
      # label for the same underlying LTI app.
      @external_tool_instance_id_to_url = {}

      # The tool usage summary is keyed by external_tool['course_navigation']['url'] if available; otherwise by external_tool['url'].
      @tool_url_to_summary = {}

      # The detailed course navigation usage report is a CSV of tool + course-site rows.
      @course_to_visible_tools = {}
    end

    def run
      collect_account_external_tools
      collect_course_external_tools
      @summary_report = generate_summary_report
      @courses_report = generate_courses_report
      logger.warn "Summary LTI usage report for #{@sis_term_id} is at #{@summary_report}"
      logger.warn "Detailed LTI usage report for #{@sis_term_id} is at #{@courses_report}"
    end

    def generate_summary_report
      filename = "#{@export_dir}/lti_usage_summary-#{file_safe(@sis_term_id)}-#{DateTime.now.strftime('%F')}.csv"
      csv = CSV.open(
        filename, 'wb',
        {
          headers: ['Tool', 'URL', 'Accounts', 'Courses Visible'],
          write_headers: true
        }
      )
      @tool_url_to_summary.each_value do |summary|
        courses_count = summary[:nbr_courses_visible]
        if (courses_count == 0) && !summary[:course_tool]
          courses_count = 'N/A'
        end
        csv << {
          'Tool' => summary[:label],
          'URL' => summary[:url],
          'Accounts' => summary[:accounts].join(', '),
          'Courses Visible' => courses_count
        }
      end
      csv.close
      filename
    end

    def generate_courses_report
      filename = "#{@export_dir}/lti_usage_courses-#{file_safe(@sis_term_id)}-#{DateTime.now.strftime('%F')}.csv"
      csv = CSV.open(
        filename, 'wb',
        {
          headers: ['Course URL', 'Name', 'Tool', 'Teacher', 'Email'],
          write_headers: true
        }
      )
      @course_to_visible_tools.each do |canvas_course_id, course_info|
        tool_urls = course_info[:tools]
        teachers = Canvas::CourseTeachers.new(course_id: canvas_course_id).full_teachers_list[:body]
        teacher = teachers.first || {}
        tool_urls.each do |tool_url|
          csv << {
            'Course URL' => "#{Settings.canvas_proxy.url_root}/courses/#{canvas_course_id}",
            'Name' => course_info[:name],
            'Tool' => @tool_url_to_summary[tool_url][:label],
            'Teacher' => teacher['name'],
            'Email' => teacher['email']
          }
        end
      end
      csv.close
      filename
    end

    def collect_course_external_tools
      fetch_courses.each do |course_row|
        next if course_row['status'] == 'unpublished'
        canvas_course_id = course_row['canvas_course_id']
        proxy = Canvas::ExternalTools.new(canvas_course_id: canvas_course_id)
        external_tool_additions = proxy.external_tools_list
        if external_tool_additions.present?
          external_tool_additions.each do |tool|
            tool_url = merge_tool_definition(tool)
            if tool['course_navigation'].blank? && tool_url.present?
              # This will not appear in course tabs, and so it needs to be
              # noted here.
              merge_course_occurrance(course_row, tool_url)
            end
          end
        end
        tabs = proxy.course_site_tab_list
        tabs.each do |tab|
          if tab['type'] == 'external' && tab['hidden'].blank?
            if (tool_id_match = /context_external_tool_([0-9]+)/.match tab['id'])
              tool_id = tool_id_match[1].to_i
              tool_url = @external_tool_instance_id_to_url[tool_id]
              merge_course_occurrance(course_row, tool_url)
            end
          end
        end
      end
      # Useful for debugging.
      logger.info "external_tool_instance_id_to_url = #{@external_tool_instance_id_to_url}"
      @tool_url_to_summary
    end

    def merge_course_occurrance(course_row, tool_url)
      canvas_course_id = course_row['canvas_course_id']
      unless (summary = @tool_url_to_summary[tool_url])
        logger.error "Missing tool URL for tab #{tab} in course ID #{canvas_course_id}"
        return
      end
      summary[:nbr_courses_visible] += 1
      unless COMMONPLACE_APPS.match tool_url
        @course_to_visible_tools[canvas_course_id] ||= {
          name: course_row['short_name'],
          tools: []
        }
        @course_to_visible_tools[canvas_course_id][:tools] << tool_url
      end
    end

    def merge_tool_definition(tool)
      id = tool['id']
      if (course_navigation = tool['course_navigation'])
        url = course_navigation['url']
        label = course_navigation['label']
      end
      url ||= tool['url'] || tool['domain']
      label ||= tool['name']
      if url.blank?
        logger.error "No URL for external tool: #{tool}"
        return
      end
      url = url.strip
      @external_tool_instance_id_to_url[id] = url
      if @tool_url_to_summary[url].blank?
        @tool_url_to_summary[url] = {
          url: url,
          label: label && label.strip,
          course_tool: course_navigation.present?,
          accounts: [],
          nbr_courses_visible: 0
        }
      end
      url
    end

    def collect_account_external_tools
      fetch_account_ids.each do |canvas_account_id|
        list = Canvas::ExternalTools.new(canvas_account_id: canvas_account_id).external_tools_list
        list.each do |tool|
          url = merge_tool_definition tool
          @tool_url_to_summary[url][:accounts] << canvas_account_id
        end
      end
      @tool_url_to_summary
    end

    def fetch_account_ids
      top_account_id = Settings.canvas_proxy.account_id
      canvas_account_ids = [top_account_id]
      subaccounts_csv = Canvas::Report::Subaccounts.new(account_id: top_account_id).get_csv
      subaccounts_csv.each {|row| canvas_account_ids << row['canvas_account_id']}
      canvas_account_ids
    end

    def fetch_courses
      Canvas::Report::Courses.new(account_id: Settings.canvas_proxy.account_id).get_csv @sis_term_id
    end

  end
end
