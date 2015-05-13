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
        # Verify backwards compatibility
        expect(feed[:videos]).to be_empty
        expect(feed[:audio]).to be_empty
        expect(feed[:itunes]['audio']).to be_nil
        expect(feed[:itunes]['video']).to be_nil
      end
    end

    context 'one matching course' do
      let(:feed) do
        Webcast::Merged.new(2014, 'B', [1, 87432], options).get_feed
      end
      it 'returns course media' do
        expect(feed[:media]['2014-B-1']).to eq Webcast::Recordings::ERRORS
        videos = feed[:media]['2014-B-87432'][:videos]
        expect(videos).to have(31).items
        # Verify backwards compatibility
        expect(feed[:videos]).to eq videos
        expect(feed[:video_error_message]).to be_nil
      end
    end

    context 'two matching course' do
      let(:feed) do
        Webcast::Merged.new(2014, 'B', [1, 87432, 2, 76207], options).get_feed
      end
      it 'returns course media' do
        expect(feed[:video_error_message]).to be_nil
        expect(feed[:media]['2014-B-1']).to eq Webcast::Recordings::ERRORS
        expect(feed[:media]['2014-B-2']).to eq Webcast::Recordings::ERRORS

        stat_131A = feed[:media]['2014-B-87432']
        pb_hlth_241 = feed[:media]['2014-B-76207']
        expect(stat_131A[:videos]).to have(31).items
        expect(pb_hlth_241[:videos]).to have(35).items
        # Verify backwards compatibility. The feed[:videos] property is a union of ALL videos in the feed.
        expect(feed[:videos]).to match_array(pb_hlth_241[:videos] + stat_131A[:videos])
        expect(feed[:audio]).to be_empty
        expect(feed[:itunes]['audio']).to be_nil
      end
    end

    context 'cross-listed CCNs in merged feed' do
      let(:feed) do
        Webcast::Merged.new(2015, 'B', [51990, 5915], options).get_feed
      end
      it 'returns course media' do
        expect(feed[:video_error_message]).to be_nil
        ls_C70U = feed[:media]['2015-B-51990']
        astro_C10 = feed[:media]['2015-B-5915']
        expect(ls_C70U[:videos]).to have(28).items
        expect(astro_C10[:videos]).to have(28).items
        # These are cross-listed CCNs so we only include unique recordings
        expect(feed[:videos]).to have(28).items
        expect(feed[:videos]).to match_array astro_C10[:videos]
        expect(feed[:audio]).to match_array astro_C10[:audio]
      end
    end

  end
end
