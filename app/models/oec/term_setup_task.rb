module Oec
  class TermSetupTask < Task

    def run_internal
      log :info, "Will create initial folders and files for term #{@term_code}"

      term_folder = create_folder @term_code
      %w(departments exports imports reports).each do |folder_name|
        create_folder(folder_name, term_folder)
      end
      supplemental_sources = create_folder('supplemental_sources', term_folder)

      find_previous_term_csvs

      [Oec::CourseInstructors, Oec::CourseSupervisors, Oec::Courses, Oec::Instructors, Oec::Supervisors].each do |worksheet_class|
        if @previous_term_csvs[worksheet_class]
          copy_file(@previous_term_csvs[worksheet_class], supplemental_sources)
        else
          log :info, "Could not find previous sheet '#{worksheet_class.export_name}' for copying; will create header-only file"
          export_sheet_headers(worksheet_class, supplemental_sources)
        end
      end
    end

    def find_previous_term_csvs
      @previous_term_csvs = {}
      if (previous_term_folder = find_previous_term_folder)
        if (previous_supplemental_sources = @remote_drive.find_first_matching_folder('supplemental_sources', previous_term_folder))
          @previous_term_csvs[Oec::Instructors] = @remote_drive.find_first_matching_item('instructors', previous_supplemental_sources)
          @previous_term_csvs[Oec::Supervisors] = @remote_drive.find_first_matching_item('supervisors', previous_supplemental_sources)
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
  end
end
