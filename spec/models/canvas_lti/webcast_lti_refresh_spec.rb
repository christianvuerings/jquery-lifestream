describe CanvasLti::WebcastLtiRefresh do

  let(:webcast_tool_id) { rand(999999) }
  let(:term_yr) { 2015 }
  let(:term_cd) { 'B' }
  let(:ccn_with_webcast) { 51990 }
  let(:ineligible_ccn_without_webcast) { 00000 }
  let(:eligible_ccn_without_webcast) { 51992 }
  let(:course_with_webcast) {[
    { :term_yr => term_yr, :term_cd => term_cd, :ccn => ccn_with_webcast },
    { :term_yr => term_yr, :term_cd => term_cd, :ccn => ineligible_ccn_without_webcast },
  ]}

  context 'fake proxy' do
    subject { CanvasLti::WebcastLtiRefresh.new(%w(TERM:2015-B), webcast_tool_id, {fake: true}) }
    before do
      report_spring_2015 = CSV.read('fixtures/webcast/canvas-sections-report_2015-B.csv', {headers: true})
      allow_any_instance_of(Canvas::Report::Sections).to receive(:get_account_csv).with('provisioning', 'sections', 'TERM:2015-B').and_return report_spring_2015
      recordings = { :courses => {'2015-B-51990' => {} } }
      allow_any_instance_of(Webcast::Recordings).to receive(:request_internal).and_return recordings
      eligible = {'spring-2015' => [ccn_with_webcast, eligible_ccn_without_webcast]}
      allow_any_instance_of(Webcast::SignUpEligible).to receive(:request_internal).and_return eligible
    end

    context 'sign-up phase is open' do
      context 'course site has webcast' do
        before do
          allow_any_instance_of(Canvas::CourseSections).to receive(:official_section_identifiers).and_return course_with_webcast
        end

        it 'should show the Webcast tool because it has videos' do
          allow_any_instance_of(Canvas::ExternalTools).to receive(:find_canvas_course_tab).and_return({ 'id' => 1, 'position' => 16, 'hidden' => true })
          expect(Webcast::CourseSiteLog).to receive(:find_by).exactly(2).times.with(anything).and_return nil
          allow_any_instance_of(Canvas::ExternalTools).to receive(:show_course_site_tab).and_return :return
          modified_tab_hash = subject.refresh_canvas
          expect(modified_tab_hash.has_key? '1336653').to be true
        end
        it 'should not un-hide the Webcast tool because it was previously un-hidden' do
          log_entry = Webcast::CourseSiteLog.new(webcast_tool_unhidden_at: Time.zone.yesterday)
          %w(1336761 1336653).each do |id|
            expect(Webcast::CourseSiteLog).to receive(:find_by).once.with({ :canvas_course_site_id => id }).and_return log_entry
          end
          # Canvas docs say 'hidden' property not present when value is false
          allow_any_instance_of(Canvas::ExternalTools).to receive(:find_canvas_course_tab).and_return({ 'id' => 1, 'position' => 16, 'hidden' => true })
          expect(subject.refresh_canvas).to be_empty
        end
      end

      context 'course site is ineligible, no recordings' do
        before do
          ineligible = [ { :term_yr => term_yr, :term_cd => term_cd, :ccn => ineligible_ccn_without_webcast } ]
          allow_any_instance_of(Canvas::CourseSections).to receive(:official_section_identifiers).and_return ineligible
        end

        it 'should skip courses with no recordings' do
          expect(subject.refresh_canvas).to be_empty
        end
      end

      context 'course site has no webcast but course is eligible and sign up is active' do
        let(:tab) { { 'id' => rand(9999999), 'hidden' => true } }
        before do
          eligible = [ { :term_yr => term_yr, :term_cd => term_cd, :ccn => eligible_ccn_without_webcast } ]
          allow_any_instance_of(Canvas::CourseSections).to receive(:official_section_identifiers).and_return eligible
        end

        it 'should un-hide Webcast tool' do
          allow_any_instance_of(CanvasLti::WebcastLtiRefresh).to receive(:is_canvas_tab_hidden?).and_return true
          allow_any_instance_of(Canvas::ExternalTools).to receive(:find_canvas_course_tab).and_return tab
          allow_any_instance_of(Canvas::ExternalTools).to receive(:show_course_site_tab).and_return tab
          allow_any_instance_of(Webcast::CourseSiteLog).to receive(:find_by).with(anything).and_return nil
          modified_tab_hash = subject.refresh_canvas
          expect(modified_tab_hash.has_key? '1336653').to be true
        end
      end
    end

    context 'sign-up phase is closed' do
      context 'eligible course with no recordings' do
        let(:tab_id) { rand(9999999) }
        before do
          eligible = [ { :term_yr => term_yr, :term_cd => term_cd, :ccn => eligible_ccn_without_webcast } ]
          allow_any_instance_of(Canvas::CourseSections).to receive(:official_section_identifiers).and_return eligible
          allow_any_instance_of(Webcast::SystemStatus).to receive(:get).and_return({ :isSignUpActive => false })
        end

        it 'should hide webcast tab' do
          tab = { 'id' => tab_id, 'position' => 16 }
          allow_any_instance_of(Canvas::ExternalTools).to receive(:find_canvas_course_tab).with(webcast_tool_id).and_return tab
          hidden_tab = { 'id' => tab_id, 'position' => 16, 'hidden' => true }
          allow_any_instance_of(Canvas::ExternalTools).to receive(:hide_course_site_tab).with(tab).and_return hidden_tab
          allow_any_instance_of(Webcast::CourseSiteLog).to receive(:create).with anything
          expect(subject.refresh_canvas).to have(2).items
        end
        it 'should not hide the already hidden tab' do
          tab = { 'id' => tab_id, 'position' => 16, 'hidden' => true }
          allow_any_instance_of(Canvas::ExternalTools).to receive(:find_canvas_course_tab).with(webcast_tool_id).and_return tab
          allow_any_instance_of(Canvas::ExternalTools).to receive(:show_course_site_tab).and_raise StandardError
          expect(subject.refresh_canvas).to be_empty
        end
      end
    end
  end
end
