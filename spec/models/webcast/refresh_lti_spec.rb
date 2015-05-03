describe Webcast::Recordings do

  let(:term_yr) { 2014 }
  let(:term_cd) { 'B' }
  let(:course_id) { 1289865 }
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
    subject { Webcast::RefreshLTI.new({course_id: course_id, fake: true}) }

    context 'course site has webcast' do
      before do
        allow_any_instance_of(Canvas::CourseSections).to receive(:official_section_identifiers).and_return course_with_webcast
      end
      it 'should show the Webcast tool' do
        expect(Webcast::CourseSiteLog).to receive(:find_by).with({ canvas_course_site_id: course_id }).and_return nil
        expect(Webcast::CourseSiteLog).to receive(:create).with({ canvas_course_site_id: course_id, webcast_tool_unhidden_at: anything }).and_return(:return_value)
        allow_any_instance_of(Webcast::RefreshLTI).to receive(:show_webcast_tool_on_course_site).and_return true
        expect(subject.refresh_canvas).to eq(:return_value)
      end

      it 'should not unhide the Webcast tool because it was previously unhidden' do
        log_entry = Webcast::CourseSiteLog.new(webcast_tool_unhidden_at: Time.zone.yesterday)
        expect(Webcast::CourseSiteLog).to receive(:find_by).with({ canvas_course_site_id: course_id }).and_return log_entry
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

  end
end
