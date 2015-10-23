module Oec
  module Folder

    FOLDER_TITLES = {
      confirmations: 'departments',
      merged_confirmations: 'departments',
      logs: 'logs',
      overrides: 'overrides',
      published: 'exports',
      sis_imports: 'imports'
    }

    FOLDER_TITLES.each do |key, title|
      define_singleton_method(key) { title }
    end

  end
end
