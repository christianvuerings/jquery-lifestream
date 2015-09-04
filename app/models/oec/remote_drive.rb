module Oec
  class RemoteDrive < GoogleApps::SheetsManager

    def initialize
      super(Settings.oec.google.uid, Settings.oec.google.marshal_dump)
    end

    def find_dept_courses_spreadsheet(term_code, dept_code)
      dept_folder = find_folder_managed_by_dept(term_code, dept_code)
      dept_folder ? find_first_matching_item('Courses', dept_folder) : nil
    end

    def find_first_matching_folder(title, parent=nil)
      find_folders_by_title(title, folder_id(parent)).first
    end

    def find_first_matching_item(title, parent=nil)
      find_items_by_title(title, parent_id: folder_id(parent)).first
    end

    private

    def find_folder_managed_by_dept(term_code, dept_code)
      term_folder = find_first_matching_folder term_code
      term_folder ? find_first_matching_folder(Berkeley::Departments.get(dept_code, concise: true), term_folder) : nil
    end

    def folder_id(folder)
      folder ? folder.id : 'root'
    end

  end
end
