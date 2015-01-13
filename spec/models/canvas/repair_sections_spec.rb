require "spec_helper"

describe Canvas::RepairSections do
  let! (:fake_sections_report_proxy) { Canvas::SectionsReport.new(fake: true) }
  let! (:fake_import_proxy) { Canvas::SisImport.new(fake: true) }

  context 'when working from fake proxies' do
    let (:fake_term) { Canvas::Proxy.current_sis_term_ids[0] }
    before {Canvas::SectionsReport.stub(:new).and_return(fake_sections_report_proxy)}
    before {Canvas::SisImport.stub(:new).and_return(fake_import_proxy)}
    it 'adds a missing SIS course ID' do
      fake_import_proxy.should_receive(:generate_course_sis_id).with('1093165').and_call_original
      subject.repair_sis_ids_for_term(fake_term)
    end
  end

end
