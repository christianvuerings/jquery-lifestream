class CanvasRepairSections < CanvasCsv
  include ClassLogger

  def repair_sis_ids_for_term(term_id)
    report_proxy = CanvasSectionsReportProxy.new
    csv = report_proxy.get_csv(term_id)
    if (csv)
      update_proxy = CanvasSisImportProxy.new
      csv.each do |row|
        if (sis_section_id = row['section_id'])
          sis_course_id = row['course_id']
          if (sis_course_id.blank?)
            logger.warn("Canvas section has SIS ID but course does not: #{row}")
            response = update_proxy.generate_course_sis_id(row['canvas_course_id'])
            if response
              course_data = JSON.parse(response.body)
              logger.warn("Added SIS ID to Canvas course: #{course_data}")
            end
          end
        end
      end
    end
  end

end
