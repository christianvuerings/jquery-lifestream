describe MyClasses::Merged do
  let(:user_id) {rand(99999).to_s}
  let(:feed) { MyClasses::Merged.new(user_id).get_feed }

  describe '#get_feed_internal' do
    context 'when no campus course associations or LMS access' do
      before { allow(Canvas::Proxy).to receive(:access_granted?).with(user_id).and_return false }
      before { allow(Sakai::Proxy).to receive(:access_granted?).with(user_id).and_return false }
      before { allow(CampusOracle::UserCourses::All).to receive(:new).and_return double({get_all_campus_courses: {}}) }
      it 'includes term with no classes' do
        expect(feed[:current_term]).to be_present
        expect(feed[:classes]).to eq []
        expect(feed).not_to include :gradingInProgressClasses
      end
    end
    context 'when an instructor in the test data', if: CampusOracle::Queries.test_data? do
      let(:user_id) {'238382'}

      shared_examples 'a feed with instructor classes' do
        it 'contains at least one class for the instructor' do
          instructing_classes = subject.select {|entry| entry[:role] == 'Instructor' }
          expect(instructing_classes).not_to be_empty
          instructing_classes.each {|c| expect(c[:site_url]).to be_present}
        end
      end

      context 'term in progress' do
        subject { feed[:classes] }
        it_should_behave_like 'a feed with instructor classes'
        it 'does not report grading in progress' do
          expect(feed).not_to include :gradingInProgressClasses
        end
      end

      context 'term just ended' do
        before { allow(Settings.terms).to receive(:fake_now).and_return(DateTime.parse('2013-12-30')) }
        subject { feed[:gradingInProgressClasses] }
        it_should_behave_like 'a feed with instructor classes'
        it 'includes empty class list for current term' do
          expect(feed[:classes]).to be_empty
        end
      end
    end
  end

  describe '#expire_cache' do
    let(:user_cache_key) {MyClasses::Merged.cache_key(user_id)}
    before {Rails.cache.write(user_cache_key, 'myclasses cached user value')}
    it 'clears user cache' do
      MyClasses::Merged.new(user_id).expire_cache
      expect(Rails.cache.fetch(user_cache_key)).to eq nil
    end
  end

end
