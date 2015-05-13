describe Canvas::WebcastLtiRefresh do

  let(:term_yr) { 2015 }
  let(:term_cd) { 'B' }
  let(:ccn_with_webcast) { 51990 }
  let(:ccn_without_webcast) { 99999 }
  let(:course_with_webcast) {[
    { :term_yr => term_yr, :term_cd => term_cd, :ccn => ccn_with_webcast },
    { :term_yr => term_yr, :term_cd => term_cd, :ccn => ccn_without_webcast },
  ]}
  let(:course_without_webcast) {[
    { :term_yr => term_yr, :term_cd => term_cd, :ccn => ccn_without_webcast },
  ]}

  # Refresh Webcast LTI configuration on Canvas course sites
  context 'a fake proxy' do
    subject { Canvas::WebcastLtiRefresh.new(%w(TERM:2014-D TERM:2015-B), 1234, {fake: true}) }

    before do
      report_fall_2014 = CSV.read('fixtures/webcast/canvas-sections-report_2014-D.csv', {headers: true})
      allow_any_instance_of(Canvas::Report).to receive(:get_account_csv).with('provisioning', 'sections', 'TERM:2014-D').and_return report_fall_2014
      report_spring_2015 = CSV.read('fixtures/webcast/canvas-sections-report_2015-B.csv', {headers: true})
      allow_any_instance_of(Canvas::Report).to receive(:get_account_csv).with('provisioning', 'sections', 'TERM:2015-B').and_return report_spring_2015
    end

    context 'course site has webcast' do
      before do
        allow_any_instance_of(Canvas::CourseSections).to receive(:official_section_identifiers).and_return course_with_webcast
      end

      it 'should show the Webcast tool because it has videos' do
        allow_any_instance_of(Canvas::ExternalTools).to receive(:find_canvas_course_tab).and_return({ 'id' => 1, 'hidden' => true })
        expect(Webcast::CourseSiteLog).to receive(:find_by).exactly(2).times.with(anything).and_return nil
        allow_any_instance_of(Canvas::ExternalTools).to receive(:show_course_site_tab).and_return :return
        modified_tab_hash = subject.refresh_canvas
        expect(modified_tab_hash.has_key? '1336653').to be true
      end

      it 'should not un-hide the Webcast tool because it was previously un-hidden' do
        log_entry = Webcast::CourseSiteLog.new(webcast_tool_unhidden_at: Time.zone.yesterday)
        expect(Webcast::CourseSiteLog).to receive(:find_by).exactly(2).times.with(anything).and_return log_entry
        # Canvas docs say 'hidden' property not present when value is false
        allow_any_instance_of(Canvas::ExternalTools).to receive(:find_canvas_course_tab).and_return({ 'id' => 1, 'hidden' => true })
        expect(subject.refresh_canvas).to be_empty
      end
    end

    context 'course site has no webcast' do
      before do
        allow_any_instance_of(Canvas::CourseSections).to receive(:official_section_identifiers).and_return course_without_webcast
      end
      it 'should skip courses with no recordings' do
        expect(subject.refresh_canvas).to be_empty
      end

      it 'should not hide Webcast tool for course that missed sign up opportunity and is already hidden' do
        allow_any_instance_of(Webcast::SystemStatus).to receive(:get).and_return({ 'is_sign_up_active' => false })
        allow_any_instance_of(Webcast::CourseMedia).to receive(:get_feed).and_return({})
        tab = { 'id' => rand(9999999), 'hidden' => true }
        allow_any_instance_of(Canvas::ExternalTools).to receive(:find_canvas_course_tab).and_return tab
        expect(subject.refresh_canvas).to be_empty
      end
    end

    context 'course site has no webcast but course is eligible and sign up is active' do
      let(:tab) { { 'id' => rand(9999999), 'hidden' => true } }

      it 'should un-hide Webcast tool because course is in eligible room' do
        allow_any_instance_of(Canvas::WebcastLtiRefresh).to receive(:is_canvas_tab_hidden?).and_return true
        allow_any_instance_of(Canvas::ExternalTools).to receive(:find_canvas_course_tab).and_return tab
        allow_any_instance_of(Canvas::ExternalTools).to receive(:show_course_site_tab).and_return tab
        allow_any_instance_of(Webcast::CourseSiteLog).to receive(:find_by).with(anything).and_return nil
        modified_tab_hash = subject.refresh_canvas
        expect(modified_tab_hash.has_key? '1336653').to be true
      end
    end

  end
end
