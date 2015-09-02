require 'spec_helper'

describe EtsBlog::ReleaseNotes do

  let (:fake_proxy) { EtsBlog::ReleaseNotes.new({fake: true}) }
  let (:real_proxy) { EtsBlog::ReleaseNotes.new({fake: false}) }
  let (:feed_uri) { URI.parse(Settings.blog_latest_release_notes_feed_proxy.base_url) }

  context 'fetching fake data feed' do
    include_context 'it writes to the cache'
    subject { fake_proxy.get_latest }

    it_behaves_like 'a polite HTTP client'

    it 'should have the expected fake data' do
      expect(subject[:title]).to eq 'CalCentral v.42 (Sprint 44) Release Notes, 8/27/14'
      expect(subject[:link]).to eq 'https://ets.berkeley.edu/article/calcentral-v42-sprint-44-release-notes-82714'
      expect(subject[:timestamp][:dateString]).to eq 'Aug 27'
      text = subject[:snippet]
      expect(text).to include 'was deployed'
      expect(text).not_to include ' read more'
    end
  end

  context 'getting real data feed', testext: true do
    include_context 'it writes to the cache'
    subject { real_proxy.get_latest }
    it { is_expected.to be_blank }
    its([:link]) { is_expected.to be }
  end

  context 'server 404s' do
    include_context 'it writes to the cache'
    after(:each) { WebMock.reset! }
    subject { real_proxy.get_latest }

    context '404 error on remote server' do
      before do
        stub_request(:any, /.*#{feed_uri.hostname}.*/).to_return(status: 404)
      end
      it { is_expected.to be_blank }
    end
  end

  context 'server errors' do
    include_context 'it writes to the cache'
    after(:each) { WebMock.reset! }
    subject { real_proxy.get_latest }

    context 'unreachable remote server (connection errors)' do
      before do
        stub_request(:any, /.*#{feed_uri.hostname}.*/).to_raise(Errno::ECONNREFUSED)
      end
      it { is_expected.to be_blank }
    end

    context 'error on remote server (5xx errors)' do
      before do
        stub_request(:any, /.*#{feed_uri.hostname}.*/).to_return(status: 506)
      end
      it { is_expected.to be_blank }
    end
  end

end
