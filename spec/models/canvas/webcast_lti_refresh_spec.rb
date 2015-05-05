describe Canvas::WebcastLtiRefresh do

  let(:term_yr) { 2014 }
  let(:term_cd) { 'B' }
  let(:canvas_course_id) { 1289865 }
  let(:canvas_webcast_tool_id) { 1234 }
  let(:ccn_with_webcast) { 87432 }
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
    subject { Canvas::WebcastLtiRefresh.new({canvas_course_id: canvas_course_id, canvas_webcast_tool_id: canvas_webcast_tool_id, fake: true}) }

    context 'course site has webcast' do
      before do
        allow_any_instance_of(Canvas::CourseSections).to receive(:official_section_identifiers).and_return course_with_webcast
      end

      it 'should show the Webcast tool because it has videos' do
        allow_any_instance_of(Canvas::ExternalTools).to receive(:find_canvas_course_tab).and_return({ 'id' => 1 })
        expect(Webcast::CourseSiteLog).to receive(:find_by).with({ canvas_course_site_id: canvas_course_id }).and_return nil
        allow_any_instance_of(Canvas::ExternalTools).to receive(:show_course_site_tab).and_return(:return_value)
        expect(subject.refresh_canvas).to eq(:return_value)
      end

      it 'should not un-hide the Webcast tool because it was previously un-hidden' do
        log_entry = Webcast::CourseSiteLog.new(webcast_tool_unhidden_at: Time.zone.yesterday)
        expect(Webcast::CourseSiteLog).to receive(:find_by).with(anything).and_return log_entry
        # Canvas docs say 'hidden' property not present when value is false
        allow_any_instance_of(Canvas::ExternalTools).to receive(:find_canvas_course_tab).and_return({ 'id' => 1 })
        expect(subject.refresh_canvas).to be_nil
      end

      it 'should not un-hide the Webcast tool because it is already un-hidden' do
        allow_any_instance_of(Canvas::ExternalTools).to receive(:find_canvas_course_tab).and_return({ 'id' => 1, 'hidden' => true })
        expect(subject.refresh_canvas).to be_nil
      end
    end

    context 'course site has no webcast' do
      before do
        allow_any_instance_of(Canvas::CourseSections).to receive(:official_section_identifiers).and_return course_without_webcast
      end
      it 'should skip course sites that have no webcast recordings' do
        expect(subject.refresh_canvas).to be_nil
      end
    end

    context 'course site has no webcast but course is eligible and sign up is active' do
      before do
        allow_any_instance_of(Canvas::CourseSections).to receive(:official_section_identifiers).and_return course_without_webcast
      end
      it 'should un-hide Webcast tool because course is in eligible room' do
        allow_any_instance_of(Canvas::WebcastLtiRefresh).to receive(:is_canvas_tab_hidden?).and_return true
        allow_any_instance_of(Canvas::ExternalTools).to receive(:find_canvas_course_tab).and_return({ 'id' => 1 })
        expect(Webcast::CourseSiteLog).to receive(:find_by).with({ canvas_course_site_id: canvas_course_id }).and_return nil
        allow_any_instance_of(Canvas::ExternalTools).to receive(:show_course_site_tab).and_return(:return_value)
        expect(subject.refresh_canvas).to eq(:return_value)
      end
    end

  end
end
