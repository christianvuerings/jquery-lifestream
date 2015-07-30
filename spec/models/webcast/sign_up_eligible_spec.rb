describe Webcast::SignUpEligible do

  let (:eligible_for_webcast_json_uri) { URI.parse "#{Settings.webcast_proxy.base_url}/warehouse/eligible-for-webcast.json" }

  context 'a fake proxy' do
    context 'sign-up phase is open' do
      subject { Webcast::SignUpEligible.new({:fake => true}) }

      it 'should return all test data' do
        terms = subject.get
        expect(terms).to have(3).items
        expect(terms['fall-2015']).to be_empty
        expect(terms['spring-2015']).to contain_exactly(5915, 51992)
      end
    end

    context 'no eligible CCNs' do
      subject { Webcast::SignUpEligible.new }
      before do
        expect(subject).to receive(:get_json_data).exactly(1).times.and_return({})
      end
      it 'should handle empty feed with grace' do
        expect(subject.get).to be_empty
      end
    end

    context 'sign-up phase is closed' do
      before {
        allow_any_instance_of(Webcast::SystemStatus).to receive(:get).and_return({ :isSignUpActive => false })
      }
      subject { Webcast::SignUpEligible.new({:fake => true}) }

      it 'should return all test data' do
        terms = subject.get
        expect(terms).to_not be_empty
      end
    end

    context 'when webcast feature is disabled' do
      before { Settings.features.videos = false }
      after { Settings.features.videos = true }
      it 'should return an empty hash' do
        expect(subject.get).to be_empty
      end
    end
  end

  context 'a real, non-fake proxy', :testext => true do
    subject { Webcast::SignUpEligible.new }

    context 'real data' do
      it 'should return at least one term' do
        expect(subject.get.keys).to have_at_least(1).items
      end
    end
  end

end
