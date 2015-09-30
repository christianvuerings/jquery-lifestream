module Oec
  class ApiTaskWrapper
    include TorqueBox::Messaging::Backgroundable

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
