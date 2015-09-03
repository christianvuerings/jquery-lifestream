module Oec
  class RemoteDrive < GoogleApps::SheetsManager

    def initialize
      super(Settings.oec.google.uid, Settings.oec.google.marshal_dump)
    end

    def find_dept_courses_spreadsheet(term_code, dept_code)
      if (term_folder = find_first_matching_folder term_code)
        dept_title = Berkeley::Departments.get(dept_code, concise: true)
        dept_folder = find_first_matching_folder(dept_title, term_folder)
        find_first_matching_item('Courses', dept_folder)
      else
        nil
      end
    end

    def find_first_matching_folder(title, parent=nil)
      find_folders_by_title(title, folder_id(parent)).first
    end

    def find_first_matching_item(title, parent=nil)
      find_items_by_title(title, parent_id: folder_id(parent)).first
    end

  end
end
