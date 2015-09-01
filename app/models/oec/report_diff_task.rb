module Oec
  class ReportDiffTask < Task

    def run_internal
      unless (reports_today = find_or_create_today_reports_folder)
        raise RuntimeError, 'Failed to retrieve today\'s reports folder from remote drive'
      end
      Oec::CourseCode.by_dept_code(@course_code_filter).each do |dept_code, course_codes|
        log :info, "Diff #{@term_code} #{dept_code} spreadsheet against latest SIS data. Summaries are in remote drive: #{reports_today}"
        # More to come...
      end
    end

  end
end
