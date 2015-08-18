describe UpNext::MyUpNext do
  let(:up_next) { UpNext::MyUpNext.new(random_id).get_feed }

  let(:fake_google_proxy) { GoogleApps::EventsList.new(fake: true) }
  let(:access_granted) { true }

  before(:each) do
    allow(GoogleApps::EventsList).to receive(:new).and_return fake_google_proxy
    allow(GoogleApps::Proxy).to receive(:access_granted?).and_return access_granted
  end

  it 'should load nicely with the pre-recorded fake Google proxy feed for event#list' do
    fake_google_events_array = fake_google_proxy.events_list(maxResults: 10)
    allow(fake_google_proxy).to receive(:events_list).and_return fake_google_events_array
    expect(up_next[:items]).to have(13).items
    up_next[:items].each do |entry|
      expect(entry[:status]).not_to eq 'cancelled'
      if !entry[:start].blank?
        expect(entry[:start][:epoch]).to be > Time.new(1970, 1, 1).to_i
      end
      if !entry[:end].blank?
        expect(entry[:end][:epoch]).to be > Time.new(1970, 1, 1).to_i
      end
    end
    expect(up_next[:date]).to be_present
    expect(up_next[:date][:epoch]).to be > Time.new(1970, 1, 1).to_i
  end

  it 'should not include all-day events for tomorrow' do
    too_late = Time.zone.today.in_time_zone.to_datetime.end_of_day
    expect(up_next[:items]).not_to be_empty
    out_of_scope_items = up_next[:items].select { |entry|
      entry[:isAllDay] && DateTime.parse(entry[:start][:dateTime]) >= too_late
    }
    out_of_scope_items.size.should == 0
  end

  context 'when Google is not responsive' do
    before { allow_any_instance_of(Google::APIClient).to receive(:execute).and_raise(StandardError) }
    it 'should return an empty feed' do
      expect(up_next[:items]).to be_empty
      expect(up_next[:date][:epoch]).to be > Time.new(1970, 1, 1).to_i
    end
  end

  context 'when user is not authorized' do
    let(:access_granted) { false }
    it 'should return an empty feed' do
      expect(up_next[:items]).to be_empty
    end
  end

  context 'when Google response has incomplete contact information' do
    before do
      google_response_page = double()
      allow(google_response_page).to receive(:response).and_return double(status: 200)
      allow(google_response_page).to receive(:data).and_return({
        'items' => [{
          'kind' => 'calendar#event',
          'status' => 'confirmed',
          'summary' => 'Carouse with Oski',
          'start' => {'dateTime' => Settings.terms.fake_now.to_datetime.advance(hours: 1).to_s},
          'end' => {'dateTime' => Settings.terms.fake_now.to_datetime.advance(hours: 2).to_s},
          'organizer' => {
            'email' => 'oski@berkeley.edu',
          },
          'attendees' => [
            {
              'email' => 'kerschen@berkeley.edu',
              'responseStatus' => 'accepted'
            },
            {
              'displayName' => 'Robert Herrick',
              'email' => 'cavalier@berkeley.edu',
              'responseStatus' => 'accepted'
            },
            {
              'unexpected key' => 'unexpected value'
            },
            {
              'email' => 'oski@example.com',
              'displayName' => 'Oski the Bear',
              'responseStatus' => 'accepted'
            }
          ]
        }]
      })
      allow(fake_google_proxy).to receive(:events_list).and_return [google_response_page]
    end

    it 'should omit unparseable entries' do
      expect(up_next[:items][0][:attendees]).to have(3).items
    end

    it 'should fall back to email address if name is missing' do
      expect(up_next[:items][0][:organizer]).to eq 'oski@berkeley.edu'
      expect(up_next[:items][0][:attendees]).to match_array(['Oski the Bear', 'Robert Herrick', 'kerschen@berkeley.edu'])
    end
  end

end
