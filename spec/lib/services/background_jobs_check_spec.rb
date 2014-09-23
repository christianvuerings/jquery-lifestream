require 'spec_helper'

describe BackgroundJobsCheck do
  before do
    allow(Settings.cache).to receive(:servers).and_return(cache_servers)
    allow(ServerRuntime).to receive(:get_settings).and_return({'hostname' => hostname})
    allow(DateTime).to receive(:now).and_return(fake_now)
  end
  let(:cache_servers) { ['dev-01', 'dev-02', 'dev-03'] }
  let(:hostname) { 'dev-03' }
  let(:fake_now) { Time.zone.parse('2014-09-22 06:00').to_time }

  describe '#current_node_id' do
    context 'when more than one cache server is configured' do
      it 'uses hostname as the node ID' do
        expect(subject.current_node_id).to eq hostname
      end
    end
    context 'when only one cache server is configured' do
      let(:cache_servers) { ['localhost'] }
      it 'assumes that is the node ID' do
        expect(subject.current_node_id).to eq 'localhost'
      end
    end
  end

  describe '#check_in' do
    it 'writes timestamp to cache' do
      expect(Rails.cache).to receive(:write).once.with(
        "BackgroundJobsCheck/#{hostname}",
        fake_now,
        {expires_in: Settings.cache.expiration.BackgroundJobsCheck, force: true}
      ).and_call_original
      subject.check_in fake_now
    end
    context 'when node ID does not match cache servers configuration' do
      let(:hostname) { 'some-random-ip' }
      it 'reports an error but does not write the timestamp' do
        expect(Rails.logger).to receive(:fatal).with(/some-random-ip/).and_call_original
        expect(Rails.cache).to receive(:write).never
        subject.check_in fake_now
      end
    end
  end

  describe '#get_feed' do
    before do
      allow(Settings.background_jobs_check).to receive(:time_between_pings).and_return(10.minutes)
      allow(Rails.cache).to receive(:read) do |key|
        cache_hash[key]
      end
    end
    let(:success_cache_hash) do
      {
        'BackgroundJobsCheck/cluster' => ping_time,
        'BackgroundJobsCheck/dev-01' => ping_time,
        'BackgroundJobsCheck/dev-02' => ping_time,
        'BackgroundJobsCheck/dev-03' => ping_time
      }
    end
    let(:ping_time) { fake_now.advance(minutes: -1) }
    context 'the last check was handled by all nodes within a reasonable time' do
      let(:cache_hash) { success_cache_hash }
      it 'reports success' do
        feed = subject.get_feed
        ['status', 'dev-01', 'dev-02', 'dev-03'].each do |k|
          expect(feed[k]).to eq 'OK'
        end
        expect(feed['last_ping']).to be_present
      end
    end
    context 'a node is missing its most recent check but within the normal lag range' do
      let(:cache_hash) { success_cache_hash.merge('BackgroundJobsCheck/dev-03' => ping_time.advance(minutes: -10)) }
      it 'reports success' do
        feed = subject.get_feed
        expect(feed['status']).to eq 'OK'
        expect(feed['last_ping']).to be_present
        expect(feed['dev-01']).to eq 'OK'
        expect(feed['dev-02']).to eq 'OK'
        expect(feed['dev-03']).to eq 'OK'
      end
    end
    context 'a node recorded its most recent check longer ago than expected' do
      let(:ping_time) { fake_now.advance(minutes: -4) }
      let(:cache_hash) { success_cache_hash.merge('BackgroundJobsCheck/dev-03' => ping_time.advance(minutes: -10)) }
      it 'reports a late node' do
        feed = subject.get_feed
        expect(feed['status']).to eq 'PARTIAL'
        expect(feed['last_ping']).to be_present
        expect(feed['dev-01']).to eq 'OK'
        expect(feed['dev-02']).to eq 'OK'
        expect(feed['dev-03']).to eq 'LATE'
      end
    end
    context 'a node recorded its most recent check much longer ago than expected' do
      let(:cache_hash) { success_cache_hash.merge('BackgroundJobsCheck/dev-03' => ping_time.advance(minutes: -30)) }
      it 'reports a dead node' do
        feed = subject.get_feed
        expect(feed['status']).to eq 'PARTIAL'
        expect(feed['dev-01']).to eq 'OK'
        expect(feed['dev-02']).to eq 'OK'
        expect(feed['dev-03']).to eq 'NOT RUNNING'
      end
    end
    context 'a node has not recorded any checks' do
      let(:cache_hash) { success_cache_hash.merge('BackgroundJobsCheck/dev-03' => nil) }
      it 'reports a missing node' do
        feed = subject.get_feed
        expect(feed['status']).to eq 'PARTIAL'
        expect(feed['last_ping']).to be_present
        expect(feed['dev-01']).to eq 'OK'
        expect(feed['dev-02']).to eq 'OK'
        expect(feed['dev-03']).to eq 'MISSING'
      end
    end
    context 'no checks have been done yet' do
      let(:cache_hash) { {} }
      it 'reports that we have not started' do
        feed = subject.get_feed
        expect(feed['status']).to eq 'MISSING'
        expect(feed['last_ping']).to be_blank
      end
    end
    context 'no checks requested for a long while' do
      let(:ping_time) {fake_now.advance(hours: -1) }
      let(:cache_hash) { success_cache_hash }
      it 'reports an error' do
        feed = subject.get_feed
        expect(feed['status']).to eq 'NOT RUNNING'
        expect(feed['last_ping']).to be_present
      end
    end

  end

end
