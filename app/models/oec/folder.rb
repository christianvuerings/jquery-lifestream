module Oec
  module Folder

    FOLDER_TITLES = {
      overrides: 'Overrides',
      sis_imports: 'Step 1: SIS import',
      confirmations: 'Step 2: department confirmation',
      merged_confirmations: 'Step 3: preflight merge',
      published: 'Step 4: publication',
      logs: 'Task logs'
    }

    FOLDER_TITLES.each do |key, title|
      define_singleton_method(key) { title }
    end

  end
end
