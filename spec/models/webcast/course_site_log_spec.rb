describe Webcast::CourseSiteLog do

  describe '#lookup' do
    let(:unhidden_at) { Time.zone.now }

    before do
      Webcast::CourseSiteLog.create params(1, unhidden_at)
    end

    it 'should deny per uniqueness constraint' do
      expect {
        Webcast::CourseSiteLog.create params(1, Time.zone.yesterday)
      }.to raise_exception
    end

    it 'should not find matching record' do
      expect(Webcast::CourseSiteLog.find_by({canvas_course_site_id: 2})).to be_nil
    end

    it 'should return record with opt_out equal false' do
      record = Webcast::CourseSiteLog.find_by({ canvas_course_site_id: 1})
      expect(record).to_not be_nil
      expect(record.webcast_tool_unhidden_at.to_i).to eq unhidden_at.to_i
    end
  end

  private

  def params(course_site_id, unhidden_at)
    { canvas_course_site_id: course_site_id, webcast_tool_unhidden_at: unhidden_at }
  end

end
