module Oec
  class ValidationTask < Task

    include MergedSheetValidation

    def run_internal
      build_and_validate_export_sheets
    end

  end
end
