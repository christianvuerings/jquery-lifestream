module Oec
  class ApiTaskWrapper
    include TorqueBox::Messaging::Backgroundable

    TASK_LIST = [
      {
        name: 'TermSetupTask',
        friendlyName: 'Term setup',
        htmlDescription: 'Create a Google Drive folder under a new term code (e.g., <strong>2015-D</strong>) and populate it with initial folders and files.',
        acceptsDepartmentOptions: false
      },
      {
        name: 'SisImportTask',
        friendlyName: 'SIS data import',
        htmlDescription: 'Import course and instructor data for one or more campus departments. Imported data will appear in a new, timestamped subfolder of the <strong>imports</strong> folder.',
        acceptsDepartmentOptions: true
      },
      {
        name: 'CreateConfirmationSheetsTask',
        friendlyName: 'Create confirmation sheets',
        htmlDescription: 'Create confirmation sheets for review and edits by department administrators. Sheets will appear under the <strong>departments</strong> folder. If that folder contains a sheet named <strong>TEMPLATE</strong>, it will be used as a model for the confirmation sheets.',
        acceptsDepartmentOptions: true
      },
      {
        name: 'ReportDiffTask',
        friendlyName: 'Diff confirmation sheets',
        htmlDescription: 'Compare department confirmation sheets to the most recent SIS import data and report on differences. The diff report will appear as a new sheet in the <strong>departments</strong> folder, and will replace any previous diff report.',
        acceptsDepartmentOptions: true
      },
      {
        name: 'MergeConfirmationSheetsTask',
        friendlyName: 'Merge confirmation sheets',
        htmlDescription: 'Merge department confirmation sheets into master sheets for preflight review. Two new sheets will be created in the <strong>departments</strong> folder: <strong>Merged course confirmations</strong> and <strong>Merged supervisor confirmations</strong>.',
        acceptsDepartmentOptions: false
      },
      {
        name: 'ValidationTask',
        friendlyName: 'Validate confirmed data',
        htmlDescription: 'Run a validation report on merged confirmation sheets. Validation results will appear in a dated subfolder of the <strong>reports</strong> folder.',
        acceptsDepartmentOptions: false
      },
      {
        name: 'PublishTask',
        friendlyName: 'Publish confirmed data to Explorance',
        htmlDescription: 'Validate and export merged confirmation sheets. Files will be uploaded to the vendor only if validation passes. A copy of the uploaded data will appear in a timestamped subfolder of the <strong>exports</strong> folder.',
        acceptsDepartmentOptions: false
      }
    ]

    def initialize(task_class, params)
      @task_class = task_class
      @params = translate_params(params)
    end

    def run
      @task_class.new(@params).run
    end

    def start_in_background
      self.background.run
    end

    private

    def translate_params(params)
      term_code = Berkeley::TermCodes.from_english params['term']
      translated_params = {
        term_code: "#{term_code[:term_yr]}-#{term_code[:term_cd]}"
      }
      if params['departmentCode'].present?
        translated_params.merge!({
          dept_codes: params['departmentCode'],
          import_all: true
        })
      end
      translated_params
    end

  end
end
