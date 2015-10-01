module Oec
  class ExportAndPublishTask < Task

    def run_internal
      [Oec::ExportTask, Oec::PublishTask].each do |klass|
        klass.new(
          term_code: @term_code,
          local_write: @opts[:local_write]
        ).run
      end
    end

  end
end
