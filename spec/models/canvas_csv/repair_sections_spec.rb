describe CanvasCsv::RepairSections do
  let! (:fake_sections_report_proxy) { Canvas::Report::Sections.new(fake: true) }
  let! (:fake_import_proxy) { Canvas::SisImport.new(fake: true) }

  context 'when working from fake proxies' do
    let (:fake_term) { Canvas::Proxy.current_sis_term_ids[0] }
    before do
      allow(Canvas::Report::Sections).to receive(:new).and_return fake_sections_report_proxy
      allow(Canvas::SisImport).to receive(:new).and_return fake_import_proxy
    end
    it 'adds a missing SIS course ID' do
      expect(fake_import_proxy).to receive(:generate_course_sis_id).with('1093165').and_call_original
      subject.repair_sis_ids_for_term(fake_term)
    end
  end

end
