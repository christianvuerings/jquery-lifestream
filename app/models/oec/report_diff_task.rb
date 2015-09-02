module Oec
  class ReportDiffTask < Task

    def run_internal
      unless (reports_today = find_or_create_today_subfolder('reports'))
        raise RuntimeError, 'Failed to retrieve today\'s reports folder from remote drive'
      end
      Oec::CourseCode.by_dept_code(@course_code_filter).each do |dept_code, course_codes|
        dept_title = Berkeley::Departments.get(dept_code, true)

        log :info, "Fetch spreadsheet from remote drive: #{@term_code}/departments/#{dept_title}/Courses"

        # More to come...

        diff_file = "#{timestamp}_#{dept_title.downcase.tr(' ', '_')}_courses_diff"
        log :info, "#{dept_title} diff summary on remote drive: #{@term_code}/reports/#{datestamp}/#{diff_file}"
      end
    end

  end
end
