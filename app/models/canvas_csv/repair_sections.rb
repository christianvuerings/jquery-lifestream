module CanvasCsv
  class RepairSections < Base

    def repair_sis_ids_for_term(term_id)
      if (csv = Canvas::Report::Sections.new.get_csv term_id)
        update_proxy = Canvas::SisImport.new
        csv.each do |row|
          if row['section_id'] && row['course_id'].blank?
            logger.warn "Canvas section has SIS ID but course does not: #{row}"
            response = update_proxy.generate_course_sis_id row['canvas_course_id']
            if (course_data = response[:body])
              logger.warn "Added SIS ID to Canvas course: #{course_data}"
            end
          end
        end
      end
    end

  end
end
