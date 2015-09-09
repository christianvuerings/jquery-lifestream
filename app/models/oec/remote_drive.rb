module Oec
  class RemoteDrive < GoogleApps::SheetsManager

    def initialize
      super(Settings.oec.google.uid, Settings.oec.google.marshal_dump)
    end

    def check_conflicts_and_copy_file(file, dest_folder, opts={})
      if find_items_by_title(file.title, parent_id: folder_id(dest_folder)).any?
        raise RuntimeError, "File '#{file.title}' already exists in remote drive folder '#{dest_folder.title}'; could not copy"
      elsif (item = copy_item_to_folder(file, folder_id(dest_folder)))
        opts[:on_success].call if opts[:on_success]
        item
      else
        raise RuntimeError, "Could not copy file '#{file.title}' to '#{dest_folder.title}'"
      end
    end

    def check_conflicts_and_create_folder(folder_name, parent=nil, opts={})
      if (existing_folder = find_first_matching_folder(folder_name, parent))
        case opts[:on_conflict]
          when :return_existing
            return existing_folder
          when :error
            raise RuntimeError, "Folder '#{folder_name}' with parent '#{folder_title(parent)}' already exists on remote drive"
        end
      elsif (new_folder = create_folder(folder_name, folder_id(parent)))
        opts[:on_creation].call if opts[:on_creation]
        new_folder
      else
        raise RuntimeError, "Could not create folder '#{folder_name}' on remote drive"
      end
    end

    def check_conflicts_and_upload(item, title, type, folder, opts={})
      if find_items_by_title(title, parent_id: folder_id(folder)).any?
        raise RuntimeError, "Item '#{title}' already exists in remote drive folder '#{folder.title}'; could not upload"
      end
      upload_operation = (type == Oec::Worksheet) ?
        upload_worksheet(title, '', item, folder_id(folder)) :
        upload_file(title, '', folder_id(folder), type, item.to_s)
      unless upload_operation
        raise RuntimeError, "Item '#{title}' could not be uploaded to remote drive folder '#{folder.title}'"
      end
      opts[:on_success].call if opts[:on_success]
      item
    end

    def find_dept_courses_spreadsheet(term_code, dept_code)
      dept_name = Berkeley::Departments.get(dept_code, concise: true)
      find_nested [term_code, 'departments', dept_name, 'Courses']
    end

    def find_first_matching_folder(title, parent=nil)
      find_folders_by_title(title, folder_id(parent)).first
    end

    def find_first_matching_item(title, parent=nil)
      find_items_by_title(title, parent_id: folder_id(parent)).first
    end

    def find_nested(folder_titles, opts={})
      folder_titles.inject(nil) do |parent, title|
        if !(item = find_first_matching_item(title, parent))
          case opts[:on_failure]
          when :error
            raise RuntimeError, "Could not locate folder '#{title}' with parent '#{folder_title(parent)}' on remote drive"
          else
            return nil
          end
        end
        item
      end
    end

  end
end
