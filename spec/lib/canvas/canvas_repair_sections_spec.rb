require "spec_helper"

describe CanvasRepairSections do
  let! (:fake_sections_report_proxy) { Canvas::CanvasSectionsReportProxy.new(fake: true) }
  let! (:fake_import_proxy) { Canvas::CanvasSisImportProxy.new(fake: true) }

  context 'when working from fake proxies' do
    let (:fake_term) { Canvas::CanvasProxy.current_sis_term_ids[1] }
    before {Canvas::CanvasSectionsReportProxy.stub(:new).and_return(fake_sections_report_proxy)}
    before {Canvas::CanvasSisImportProxy.stub(:new).and_return(fake_import_proxy)}
    it 'adds a missing SIS course ID' do
      fake_import_proxy.should_receive(:generate_course_sis_id).with('1093165').and_call_original
      subject.repair_sis_ids_for_term(fake_term)
    end
  end

end
