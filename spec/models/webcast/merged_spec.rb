describe Webcast::Merged do

  context 'a fake proxy' do
    let(:options) { {:fake => true} }

    context 'no matching course' do
      let(:feed) do
        Webcast::Merged.new(rand(99999).to_s, 2014, 'B', [1], options).get_feed
      end
      before do
        expect_any_instance_of(MyAcademics::Teaching).not_to receive :new
      end
      it 'returns system status when authenticated' do
        expect(feed[:system_status][:isSignUpActive]).to be true
        # TODO: Bring 'rooms' back in the feed as needed by front-end
        # expect(feed[:rooms]).to have(26).items
        # expect(feed[:rooms]['VALLEY LSB']).to contain_exactly('2040', '2050', '2060')
        expect(feed[:media]).to be_nil
        # Verify backwards compatibility
        expect(feed[:videos]).to be_nil
        expect(feed[:audio]).to be_nil
        expect(feed[:iTunes]).to be_nil
      end
    end

    context 'one matching course' do
      let(:feed) do
        Webcast::Merged.new(rand(99999).to_s, 2014, 'B', [1, 87432], options).get_feed
      end
      before do
        courses_list = [
          {
            :classes=>[
              {
                :dept => 'PLANTBI',
                :courseCatalog => '150',
                :sections => [
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
        stat_131A = feed[:media][0]
        expect(stat_131A[:termYr]).to eq 2014
        expect(stat_131A[:termCd]).to eq 'B'
        expect(stat_131A[:ccn]).to eq '87432'
        expect(stat_131A[:deptName]).to eq 'PLANTBI'
        expect(stat_131A[:catalogId]).to eq '150'
        videos = stat_131A[:videos]
        itunes_audio_id = '819827828'
        expect(stat_131A[:iTunes][:audio]).to include itunes_audio_id
        expect(videos).to have(31).items
        # Verify backwards compatibility
        expect(feed[:videos]).to eq videos
        expect(feed[:videoErrorMessage]).to be_nil
        expect(feed[:iTunes][:audio]).to include itunes_audio_id
      end
    end

    context 'ccn formatting per convention' do
      let(:feed) do
        Webcast::Merged.new(rand(99999).to_s, 2008, 'D', [9688], options).get_feed
      end
      before do
        courses_list = [{
            :classes=>[{ :sections => [{ :ccn=>'09688', :section_number=>'101', :instruction_format=>'LEC' }] }]
          }
        ]
        expect_any_instance_of(MyAcademics::Teaching).to receive(:courses_list_from_ccns).once.and_return courses_list
      end
      it 'pads ccn with zeroes' do
        law_course = feed[:media][0]
        expect(law_course).to_not be_nil
        expect(law_course[:ccn]).to eq '09688'
        expect(law_course[:videos]).to be_empty
      end
    end

    context 'two matching course' do
      let(:ldap_uid) { '248421' }
      let(:feed) do
        Webcast::Merged.new(ldap_uid, 2014, 'B', [87432, 76207, 7620], options).get_feed
      end
      before do
        sections_with_recordings = [
          {
            :classes=>[
              {
                :sections=>[
                  {
                    :ccn=>'76207',
                    :instruction_format=>'LEC',
                    :section_number=>'101'
                  },
                  {
                    :ccn=>'87432',
                    :instruction_format=>'LEC',
                    :section_number=>'101'
                  }
                ]
              }
            ]
          }
        ]
        webcast_eligible = [
          {
            :classes=>[
              {
                :dept => 'BIO',
                :courseCatalog => '1B',
                :sections=>[
                  {
                    :ccn=>'07620',
                    :section_number=>'312',
                    :instruction_format => 'LAB',
                    :instructors=>[
                      {
                        :name=>'Paul Duguid',
                        :uid=>'18938',
                        :instructor_func=>'1'
                      },
                      {
                        :name=>'Geoffrey Nunberg',
                        :uid=>ldap_uid,
                        :instructor_func=>'3'
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
        expect_any_instance_of(MyAcademics::Teaching).to receive(:courses_list_from_ccns).with(2014, 'B', [87432, 76207]).and_return sections_with_recordings
        expect_any_instance_of(MyAcademics::Teaching).to receive(:courses_list_from_ccns).with(2014, 'B', [7620]).and_return webcast_eligible
      end
      it 'returns course media' do
        expect(feed[:videoErrorMessage]).to be_nil
        media = feed[:media]
        expect(media).to have(2).items
        pb_hlth_241 = media[0]
        stat_131A = media[1]
        expect(stat_131A[:ccn]).to eq '87432'
        expect(stat_131A[:videos]).to have(31).items
        expect(stat_131A[:instructionFormat]).to eq 'LEC'
        expect(stat_131A[:sectionNumber]).to eq '101'
        expect(stat_131A[:eligibleForSignUp]).to be_nil
        expect(pb_hlth_241[:ccn]).to eq '76207'
        expect(pb_hlth_241[:videos]).to have(35).items
        expect(pb_hlth_241[:iTunes][:video]).to include('805328862')
        expect(feed[:videos]).to match_array(pb_hlth_241[:videos] + stat_131A[:videos])
        expect(feed[:audio]).to be_empty
        expect(feed[:iTunes][:audio]).to be_nil
        expect(feed[:iTunes][:video]).to include('805328862')

        # Instructors that can sign up for Webcast
        eligible_for_sign_up = feed[:eligibleForSignUp]
        expect(eligible_for_sign_up).to have(1).items
        bio_lab = eligible_for_sign_up[0]
        expect(bio_lab[:ccn]).to eq '07620'
        expect(bio_lab[:deptName]).to eq 'BIO'
        expect(bio_lab[:catalogId]).to eq '1B'
        expect(bio_lab[:sectionNumber]).to eq '312'
        expect(bio_lab[:instructionFormat]).to eq 'LAB'
        instructors = bio_lab[:webcastAuthorizedInstructors]
        expect(instructors).to have(2).items
        expect(instructors).to have(2).items
        expect(instructors[0][:name]).to eq 'Paul Duguid'
        expect(instructors[1][:name]).to eq 'Geoffrey Nunberg'
      end
    end

    context 'cross-listed CCNs in merged feed' do
      let(:feed) do
        Webcast::Merged.new(rand(99999).to_s, 2015, 'B', [51990, 5915, 51992], options).get_feed
      end
      before do
        sections_with_recordings = [
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
        webcast_eligible = [
          {
            :classes=>[
              {
                :sections=>[
                  { :ccn=>'51992', :section_number=>'401', :instruction_format=>'DIS' }
                ]
              }
            ]
          }
        ]
        expect_any_instance_of(MyAcademics::Teaching).to receive(:courses_list_from_ccns).with(2015, 'B', [51990, 5915]).and_return sections_with_recordings
        expect_any_instance_of(MyAcademics::Teaching).to receive(:courses_list_from_ccns).with(2015, 'B', [51992]).and_return webcast_eligible
      end
      it 'returns course media' do
        expect(feed[:videoErrorMessage]).to be_nil
        media = feed[:media]
        # These are cross-listed CCNs so we only include unique recordings
        section_101 = media[0][:videos]
        expect(section_101).to have(28).items
        expect(section_101).to match_array media[1][:videos]
        # Verify CCNs not yet signed up for Webcast
        eligible = feed[:eligibleForSignUp]
        expect(eligible).to have(1).items
        expect(eligible[0][:ccn]).to eq '51992'
      end
    end
  end

  context 'a real, non-fake proxy', :testext => true do
    context 'course with zero recordings is different than course not scheduled for recordings' do
      let(:feed) do
        Webcast::Merged.new(rand(99999).to_s, 2015, 'B', [1, 58301, 56745]).get_feed
      end
      it 'identifies course that is scheduled for recordings' do
        media = feed[:media]
        recordings_planned = media[0]
        expect(recordings_planned).not_to be_nil
        expect(recordings_planned[:ccn]).to eq '58301'
        expect(recordings_planned[:videos]).to be_empty
        expect(recordings_planned[:body]).to be_nil

        recordings_exist = media[1]
        expect(recordings_exist[:ccn]).to eq '56745'
        expect(recordings_exist[:videos]).to have_at_least(10).items
        expect(recordings_exist[:body]).to be_nil
      end
    end
  end

end
