describe Webcast::Merged do

  let(:ldap_uid) { 904715 }

  context 'a fake proxy' do
    let(:options) { {:fake => true} }

    context 'no matching course' do
      let(:feed) do
        Webcast::Merged.new(ldap_uid, 2014, 'B', [1], options).get_feed
      end
      before do
        expect_any_instance_of(MyAcademics::Teaching).not_to receive :new
      end
      it 'returns system status when authenticated' do
        expect(feed[:system_status]['is_sign_up_active']).to be true
        # TODO: Bring 'rooms' back in the feed as needed by front-end
        # expect(feed[:rooms]).to have(26).items
        # expect(feed[:rooms]['VALLEY LSB']).to contain_exactly('2040', '2050', '2060')
        expect(feed[:media][2014]['B']).to be_empty
        # Verify backwards compatibility
        expect(feed[:videos]).to be_empty
        expect(feed[:audio]).to be_empty
        expect(feed[:itunes]['audio']).to be_nil
        expect(feed[:itunes]['video']).to be_nil
      end
    end

    context 'one matching course' do
      let(:feed) do
        Webcast::Merged.new(ldap_uid, 2014, 'B', [1, 87432], options).get_feed
      end
      before do
        courses_list = [
          {
            :classes=>[
              {
                :sections=>[
                  { :ccn=>'87435', :section_number=>'101', :instruction_format=>'LAB' },
                  { :ccn=>'87438', :section_number=>'102', :instruction_format=>'LAB' },
                  { :ccn=>'87444', :section_number=>'201', :instruction_format=>'LAB' },
                  { :ccn=>'87447', :section_number=>'202', :instruction_format=>'LAB' },
                  { :ccn=>'87432', :section_number=>'001', :instruction_format=>'LEC' },
                  { :ccn=>'87441', :section_number=>'002', :instruction_format=>'LEC' }
                ]
              }
            ]
          }
        ]
        expect_any_instance_of(MyAcademics::Teaching).to receive(:courses_list_from_ccns).once.and_return courses_list
      end
      it 'returns one match media' do
        spring_2014 = feed[:media][2014]['B']
        expect(spring_2014[1]).to be_nil
        videos = spring_2014['87432'][:videos]
        expect(videos).to have(31).items
        # Verify backwards compatibility
        expect(feed[:videos]).to eq videos
        expect(feed[:video_error_message]).to be_nil
      end
    end

    context 'two matching course' do
      let(:feed) do
        Webcast::Merged.new(ldap_uid, 2014, 'B', [1, 87432, 2, 76207], options).get_feed
      end
      before do
        courses_list = [
          {
            :classes=>[
              {
                :sections=>[
                  {
                    :ccn=>'87432',
                    :section_number=>'101',
                    :instruction_format=>'LEC' },
                  {
                    :ccn=>'76207',
                    :section_number=>'102',
                    :instruction_format=>'LEC',
                    :instructors=>[
                      {
                        :name=>'Paul Duguid',
                        :uid=>'18938',
                        :instructor_func=>'1'
                      },
                      {
                        :name=>'Geoffrey D. Nunberg',
                        :uid=>'248421',
                        :instructor_func=>'1'
                      },
                      {
                        :name=>'Nikolai Smith',
                        :uid=>'1016717',
                        :instructor_func=>'2'
                      }
                    ]
                  }
                ]
              }
            ]
          }
        ]
        expect_any_instance_of(MyAcademics::Teaching).to receive(:courses_list_from_ccns).once.and_return courses_list
      end
      it 'returns course media' do
        expect(feed[:video_error_message]).to be_nil
        spring_2014 = feed[:media][2014]['B']
        expect(spring_2014[1]).to be_nil
        expect(spring_2014[2]).to be_nil

        stat_131A = spring_2014['87432']
        expect(stat_131A[:videos]).to have(31).items
        expect(stat_131A[:instruction_format]).to eq 'LEC'
        expect(stat_131A[:section_number]).to eq '101'
        expect(stat_131A[:webcast_authorized_instructors]).to be_empty

        pb_hlth_241 = spring_2014['76207']
        expect(pb_hlth_241[:videos]).to have(35).items
        # Feed excludes instructors per instructor_func
        authorized_instructors = pb_hlth_241[:webcast_authorized_instructors]
        expect(authorized_instructors).to have(2).items
        expect(authorized_instructors[0][:uid]).to eq '18938'
        expect(authorized_instructors[0][:instructor_func]).to eq '1'
        expect(authorized_instructors[1][:uid]).to eq '248421'
        expect(authorized_instructors[1][:instructor_func]).to eq '1'

        # Verify backwards compatibility. The feed[:videos] property is a union of ALL videos in the feed.
        expect(feed[:videos]).to match_array(pb_hlth_241[:videos] + stat_131A[:videos])
        expect(feed[:audio]).to be_empty
        expect(feed[:itunes]['audio']).to be_nil
      end
    end

    context 'cross-listed CCNs in merged feed' do
      let(:feed) do
        Webcast::Merged.new(ldap_uid, 2015, 'B', [51990, 5915], options).get_feed
      end
      before do
        courses_list = [
          {
            :classes=>[
              {
                :sections=>[
                  { :ccn=>'05915', :section_number=>'101', :instruction_format=>'LEC' },
                  { :ccn=>'51990', :section_number=>'201', :instruction_format=>'LEC' }
                ]
              }
            ]
          }
        ]
        expect_any_instance_of(MyAcademics::Teaching).to receive(:courses_list_from_ccns).once.and_return courses_list
      end
      it 'returns course media' do
        expect(feed[:video_error_message]).to be_nil
        spring_2015 = feed[:media][2015]['B']
        # These are cross-listed CCNs so we only include unique recordings
        ccn_5915_videos = spring_2015['05915'][:videos]
        expect(ccn_5915_videos).to have(28).items
        expect(ccn_5915_videos).to match_array spring_2015['51990'][:videos]
        # TODO: remove these deprecated properties from the Webcast feed
        expect(feed[:videos]).to have(28).items
        expect(feed[:videos]).to match_array ccn_5915_videos
        expect(feed[:audio]).to match_array spring_2015['05915'][:audio]
      end
    end
  end

  context 'a real, non-fake proxy', :testext => true do
    context 'course with zero recordings is different than course not scheduled for recordings' do
      let(:feed) do
        Webcast::Merged.new(ldap_uid, 2015, 'B', [1, 58301, 56745]).get_feed
      end
      it 'identifies course that is scheduled for recordings' do
        spring_2015 = feed[:media][2015]['B']
        non_existent = spring_2015[1]
        recordings_planned = spring_2015['58301']
        recordings_exist = spring_2015['56745']
        expect(non_existent).to be_nil
        expect(recordings_planned).not_to be_nil
        expect(recordings_planned[:videos]).to be_empty
        expect(recordings_planned[:body]).to be_nil
        expect(recordings_exist[:videos]).to have_at_least(10).items
        expect(recordings_exist[:body]).to be_nil
      end
    end
  end

end
