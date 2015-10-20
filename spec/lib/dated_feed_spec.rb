describe DatedFeed do

  describe '#strptime_in_time_zone' do
    let(:bearfacts_date_format) {'%A %m/%d/%y %I:%M %p'}
    subject {DatedFeed.strptime_in_time_zone(bearfacts_date_time, bearfacts_date_format)}
    context 'during daylight savings' do
      let(:bearfacts_date_time) {'Monday 04/08/13 09:30 AM'}
      it 'can parse BearFacts XML time to proper Pacific time' do
        Time.use_zone('Pacific Time (US & Canada)') do
          expect(subject.to_time.to_i).to eq 1365438600
        end
      end
      it 'can parse BearFacts XML time as UTC as well' do
        Time.use_zone('UTC') do
          expect(subject.to_time.to_i).to eq 1365413400
        end
      end
    end
    context 'during standard time' do
      let(:bearfacts_date_time) {'Monday 12/09/13 09:00 AM'}
      it 'can parse BearFacts XML time to proper Pacific time' do
        Time.use_zone('Pacific Time (US & Canada)') do
          expect(subject.to_time.to_i).to eq 1386608400
        end
      end
      it 'can parse BearFacts XML time as UTC as well' do
        Time.use_zone('UTC') do
          expect(subject.to_time.to_i).to eq 1386579600
        end
      end
    end
  end

end
