describe MyActivities::Webcasts do
  let(:recordings_proxy) { Webcast::Recordings.new(fake: fake) }
  before { allow(Webcast::Recordings).to receive(:new).and_return recordings_proxy }

  let(:activities) do
    activities = []
    described_class.append!(uid, activities)
    activities
  end

  shared_examples 'a feed with no webcast activities' do
    it 'should append nothing' do
      expect(activities).to be_empty
    end
  end

  shared_examples 'a feed with webcast activities' do
    it 'should include notifications' do
      expect(activities).not_to be_empty
    end

    it 'should include course and uid data' do
      expect(activities).to all include({
        emitter: 'Course Captures',
        id: '',
        linkText: 'View recording',
        source: 'BIOLOGY 1A',
        summary: 'A new recording for your Fall 2013 course, General Biology Lecture, is now available.',
        type: 'webcast',
        title: 'Recording Available',
        user_id: uid
      })
    end

    it 'should include recording-specific URLs' do
      activities.each do |activity|
        expect(activity[:sourceUrl]).to match /academics.*biology-1a\?video=.+/
        expect(activity[:url]).to eq activity[:sourceUrl]
      end
    end

    it 'should only include webcasts after cutoff date' do
      expect(activities.collect{|activity| activity[:date][:epoch]}).to all be > MyActivities::Merged.cutoff_date
    end
  end

  context 'fake webcast proxy', if: CampusOracle::Connection.test_data? do
    let(:fake) { true }

    context 'student enrolled in webcast course' do
      let(:uid) { '300939' }
      it_should_behave_like 'a feed with webcast activities'
    end

    context 'instructor of webcast course' do
      let(:uid) { '238382' }
      it_should_behave_like 'a feed with webcast activities'
    end

    context 'student not enrolled in webcast course' do
      let(:uid) { '300940' }
      it_should_behave_like 'a feed with no webcast activities'
    end
  end

  context 'connection failure' do
    let(:fake) { false }
    let(:uid) { random_id }
    before { stub_request(:any, /.*/).to_raise(Errno::EHOSTUNREACH) }
    after { WebMock.reset! }

    it_should_behave_like 'a feed with no webcast activities'
  end
end
