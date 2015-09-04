module Oec
  class ReportDiffTask < Task

    def run_internal
      Oec::CourseCode.by_dept_code(@course_code_filter).each do |dept_code, course_codes|
        spreadsheet = @remote_drive.find_dept_courses_spreadsheet(@term_code, dept_code)
        dept_title = Berkeley::Departments.get(dept_code, concise: true)
        if spreadsheet
          worksheet = DiffReport.new('tmp/oec')

          # More to come...

          dept_title = Berkeley::Departments.get(dept_code, concise: true)
          file_name = "#{timestamp}_#{dept_title.downcase.tr(' ', '_')}_courses_diff"
          reports_today = find_or_create_today_subfolder('reports')
          @remote_drive.upload_worksheet(file_name, nil, worksheet, reports_today.id)
          log :info, "#{dept_code} diff summary on remote drive: #{@term_code}/reports/#{datestamp}/#{file_name}"
        else
          log :info, "No #{@term_code} diff for #{dept_title} because dept has no admin-managed spreadsheet."
        end
      end
    end

  end
end
