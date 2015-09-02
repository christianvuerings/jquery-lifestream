# encoding: utf-8

require 'spec_helper'

describe EtsBlog::ServiceAlerts do

  let(:fake_proxy) { EtsBlog::ServiceAlerts.new({fake: true}) }

  describe 'shared examples' do
    subject { EtsBlog::ServiceAlerts.new(fake: false).get_latest }
    it_behaves_like 'a polite HTTP client'
  end

  it 'should format and return the latest well-formed feed message' do
    alert = fake_proxy.get_latest
    expect(alert[:title]).to eq 'Second CalCentral test alert'
    expect(alert[:snippet]).to eq 'This is a short summary.'
    expect(alert[:link]).to eq 'https://test-ets.pantheon.berkeley.edu/news/second-calcentral-test-alert'
    expect(alert[:timestamp][:dateString]).to eq 'Jul 08'
    expect(alert[:timestamp][:epoch]).to eq 1436338800
  end

  describe 'with other mock data' do
    before { allow_any_instance_of(EtsBlog::ServiceAlerts).to receive(:mock_xml).and_return(fake_proxy.read_file('fixtures', 'xml', mock_xml_file)) }
    subject { EtsBlog::ServiceAlerts.new({fake: true}) }

    context 'when the xml contains multibyte characters' do
      let(:mock_xml_file) { 'service_alerts_feed_diacriticals.xml' }
      it 'should parse' do
        alert = subject.get_latest
        expect(alert[:title]).to eq '¡El Señor González se zampó un extraño sándwich de vodka y ajo! (¢, ®, ™, ©, •, ÷, –, ¿)'
        expect(alert[:link]).to eq 'hדג סקרן שט בים מאוכזב ולפתע מצא לו חברה'
        expect(alert[:snippet]).to eq 'جامع الحروف عند البلغاء يطلق على الكلام المركب من جميع حروف التهجي بدون تكرار أحدها في لفظ واحد، أما في لفظين فهو جائز'
      end
    end

    context 'when the alert only has a title' do
      let(:mock_xml_file) { 'service_alerts_feed_title_only.xml' }
      it 'should return basic attributes' do
        alert = subject.get_latest
        expect(alert[:title]).to be_present
        expect(alert[:link]).to be_present
        expect(alert[:timestamp][:epoch]).to be_present
        expect(alert[:snippet]).to be_blank
      end
    end

    context 'when there are no alerts in the feed' do
      let(:mock_xml_file) { 'service_alerts_feed_empty.xml' }
      it 'should return nil' do
        alert = subject.get_latest
        expect(alert).to be_blank
      end
    end

    context 'when the alert feed has a single item' do
      let(:mock_xml_file) { 'service_alerts_feed_single.xml' }
      it 'should return the item contents' do
        alert = subject.get_latest
        expect(alert[:title]).to be_present
        expect(alert[:link]).to be_present
        expect(alert[:timestamp][:epoch]).to be_present
        expect(alert[:snippet]).to be_present
      end
    end
  end

  context 'when exceptions are raised' do
    before { allow(fake_proxy).to receive(:get_feed_internal).and_raise(SocketError) }
    context 'caching failures' do
      include_context 'short-lived cache write of NilClass on failures'
      it 'should write to cache when handling exceptions' do
        expect(fake_proxy.get_latest).to be_nil
      end
    end
  end

end
