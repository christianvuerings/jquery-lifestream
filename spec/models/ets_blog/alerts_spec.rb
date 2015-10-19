# encoding: utf-8

describe EtsBlog::Alerts do

  describe 'shared examples' do
    subject { EtsBlog::Alerts.new(fake: false).get_latest }
    it_behaves_like 'a proxy logging errors'
    it_behaves_like 'a polite HTTP client'
  end

  describe 'with other mock data' do
    let(:fake_proxy) { EtsBlog::Alerts.new({fake: true}) }
    let(:empty_xml) { '<xml><node><chicken>egg</chicken></node></xml>' }
    let(:unexpected_xml) { '<xml><node><chicken>egg</chicken></node></xml>' }
    let(:xml_with_no_teaser){ Rails.root.join('fixtures', 'xml', 'app_alerts_feed_no_teaser.xml') }
    let(:xml_multibyte_characters) { Rails.root.join('fixtures', 'xml', 'app_alerts_feed_diacriticals.xml') }

    subject { fake_proxy }

    it 'should format and return the latest well-formed feed message' do
      alert = subject.get_latest
      expect(alert[:title]).to eq 'CalCentral Scheduled Upgrade (Test Announce Only)'
      expect(alert[:snippet]).to eq 'CalCentral Scheduled Upgrade (Test Announce Only)'
      expect(alert[:link]).to eq 'http://ets-dev.berkeley.edu/news/calcentral-scheduled-upgrade-test-announce-only'
      expect(alert[:timestamp][:epoch]).to eq 1393257625
    end

    context 'when the xml contains multibyte characters' do
      before { allow(fake_proxy).to receive(:get_feed).and_return(MultiXml.parse File.read(xml_multibyte_characters)) }
      include_examples 'xml with multibyte characters'
    end

    context 'when the xml is missing a teaser' do
      before { allow(fake_proxy).to receive(:get_feed).and_return(MultiXml.parse File.read(xml_with_no_teaser)) }
      include_examples 'non-empty alert'
    end

    context 'when xml data is empty' do
      before { allow(fake_proxy).to receive(:get_feed).and_return(MultiXml.parse empty_xml) }
      include_examples 'invalid alert xml'
    end

    context 'when xml data is unexpected' do
      before { allow(fake_proxy).to receive(:get_feed).and_return(MultiXml.parse unexpected_xml) }
      include_examples 'invalid alert xml'
    end

    context 'when xml data is nil' do
      before { allow(fake_proxy).to receive(:get_feed).and_return(MultiXml.parse nil) }
      include_examples 'invalid alert xml'
    end

    context 'when exceptions are raised' do
      before { allow(fake_proxy).to receive(:get_feed).and_raise(SocketError) }

      it 'should rescue exceptions and return nil from get_latest' do
        expect { fake_proxy.get_alerts }.to raise_exception
        expect { fake_proxy.get_latest }.not_to raise_exception
        expect(fake_proxy.get_latest).to be_nil
      end

      context 'caching failures' do
        include_context 'short-lived cache write of NilClass on failures'
        it 'should write to cache when handling exceptions' do
          expect { fake_proxy.get_latest }.not_to raise_exception
        end
      end
    end
  end



end
