describe Webcast::Merged do

  let(:options) { {:fake => true} }

  context '#authenticated' do

    context 'no matching course' do
      let(:feed) do
        Webcast::Merged.new(2014, 'B', [1], options).get_feed
      end

      it 'returns system status when authenticated' do
        expect(feed[:system_status]['is_sign_up_active']).to be true
        expect(feed[:rooms]).to have(26).items
        expect(feed[:rooms]['VALLEY LSB']).to contain_exactly('2040', '2050', '2060')
        course = feed[:media]['2014-B-1']
        expect(course).to eq Webcast::Recordings::ERRORS
        expect(course[:videos]).to be_nil
        expect(course[:audio]).to be_nil
      end
    end

    context 'one matching course' do
      let(:feed) do
        Webcast::Merged.new(2014, 'B', [1, 87432], options).get_feed
      end
      it 'returns course media' do
        expect(feed[:media]['2014-B-1']).to eq Webcast::Recordings::ERRORS
        expect(feed[:media]['2014-B-87432'][:videos]).to have(31).items
      end
    end

    context 'two matching course' do
      let(:feed) do
        Webcast::Merged.new(2014, 'B', [1, 87432, 2, 76207], options).get_feed
      end
      it 'returns course media' do
        expect(feed[:media]['2014-B-1']).to eq Webcast::Recordings::ERRORS
        expect(feed[:media]['2014-B-87432'][:videos]).to have(31).items
        expect(feed[:media]['2014-B-2']).to eq Webcast::Recordings::ERRORS
        expect(feed[:media]['2014-B-76207'][:videos]).to have(35).items
      end
    end

  end
end
