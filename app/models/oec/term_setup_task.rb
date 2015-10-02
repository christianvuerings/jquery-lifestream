module Oec
  class TermSetupTask < Task

    def run_internal
      log :info, "Will create initial folders and files for term #{@term_code}"

      term_folder = create_folder @term_code
      %w(exports imports logs).each do |folder_name|
        create_folder(folder_name, term_folder)
      end
      departments = create_folder('departments', term_folder)
      overrides = create_folder('overrides', term_folder)

      find_previous_term_csvs

      [Oec::CourseInstructors, Oec::CourseSupervisors, Oec::Instructors, Oec::Supervisors].each do |worksheet_class|
        if @previous_term_csvs[worksheet_class]
          copy_file(@previous_term_csvs[worksheet_class], overrides)
        else
          log :info, "Could not find previous sheet '#{worksheet_class.export_name}' for copying; will create header-only file"
          export_sheet_headers(worksheet_class, overrides)
        end
      end

      courses = Oec::Courses.new
      set_default_term_dates courses
      export_sheet(courses, overrides)

      if !@opts[:local_write] && (department_template = @remote_drive.find_nested ['templates', 'Department confirmations'])
        @remote_drive.copy_item_to_folder(department_template, departments.id, 'TEMPLATE')
      end
    end

    def find_previous_term_csvs
      @previous_term_csvs = {}
      if (previous_term_folder = find_previous_term_folder)
        if (previous_overrides = @remote_drive.find_first_matching_folder('overrides', previous_term_folder))
          @previous_term_csvs[Oec::Instructors] = @remote_drive.find_first_matching_item('instructors', previous_overrides)
          @previous_term_csvs[Oec::Supervisors] = @remote_drive.find_first_matching_item('supervisors', previous_overrides)
        end
        if (previous_exports =  @remote_drive.find_first_matching_folder('exports', previous_term_folder))
          if (most_recent_export = @remote_drive.find_folders(previous_exports.id).sort_by(&:title).last)
            @previous_term_csvs[Oec::CourseSupervisors] =  @remote_drive.find_first_matching_item('course_supervisors', most_recent_export)
          end
        end
      end
    end

    def find_previous_term_folder
      if (folders = @remote_drive.find_folders)
        folders.select { |f| f.title.match(/\d{4}-[A-D]/) && f.title < @term_code }.sort_by(&:title).last
      end
    end

    def set_default_term_dates(courses)
      term = Berkeley::Terms.fetch.campus[Berkeley::TermCodes.to_slug *@term_code.split('-')]
      courses[0] = {
        'START_DATE' => term.classes_start.strftime(Oec::Worksheet::WORKSHEET_DATE_FORMAT),
        'END_DATE' => term.instruction_end.advance(days: 2).strftime(Oec::Worksheet::WORKSHEET_DATE_FORMAT)
      }
    end
  end
end
