# encoding: utf-8

require 'spec_helper'

describe EtsBlog::Alerts do

  let(:fake_proxy) { EtsBlog::Alerts.new({fake: true}) }
  let(:real_failing_proxy) { EtsBlog::Alerts.new({fake: false}) }
  let(:bad_url) { 'http://alsdlksasgflasldsalfjsgj/snjlfdsalsfal/lsadfjfl.xml' }
  let(:bad_file_path) { '/sajdljfsjaslaslsd/garbage/some.xml' }
  let(:bad_xml) { '<xml><chicken>' }
  let(:unexpected_xml) { '<xml><node><chicken>egg</chicken></node></xml>' }
  let(:empty_xml) { '<xml></xml>' }
  let(:xml_with_no_teaser){ Rails.root.join('fixtures', 'xml', 'app_alerts_feed_no_teaser.xml') }
  let(:xml_multibye_diacriticals) { Rails.root.join('fixtures', 'xml', 'app_alerts_feed_diacriticals.xml') }

  context "failures" do
    it "not finding fake xml feed on disk should return nil" do
      fake_proxy.stub(:xml_source).and_return(bad_file_path)
      fake_proxy.get_latest.should be_nil
    end
    it "not finding real feed url should return nil" do
      real_failing_proxy.stub(:xml_source).and_return(bad_url)
      real_failing_proxy.get_latest.should be_nil
    end
    it "that receive unexpected xml data should return nil" do
      fake_proxy.stub(:get_raw_xml).and_return(unexpected_xml)
      fake_proxy.get_latest.should eq ''
    end
    it "that receive empty xml data should return nil" do
      fake_proxy.stub(:get_raw_xml).and_return(empty_xml)
      fake_proxy.get_latest.should eq ''
      fake_proxy.stub(:get_raw_xml).and_return(nil)
      fake_proxy.get_latest.should eq ''
      fake_proxy.stub(:get_raw_xml).and_return('')
      fake_proxy.get_latest.should eq ''
    end
  end

  context "successful when" do
    it "Alerts.get_latest returns four fields with values present" do
      alert = fake_proxy.get_latest
      alert.is_a?(Hash)
      alert.count.should == 4
    end
    it "the xml alert is missing a teaser" do
      fake_proxy.stub(:xml_source).and_return(xml_with_no_teaser)
      alert = fake_proxy.get_latest
      alert.is_a?(Hash)
      alert.count.should == 3
    end
    it "Alerts.get_latest formats and returns the latest single well-formed feed message" do
      alert = fake_proxy.get_latest
      alert[:title].should == 'CalCentral Scheduled Upgrade (Test Announce Only)'
      alert[:teaser].should == 'CalCentral Scheduled Upgrade (Test Announce Only)'
      alert[:url].should == 'http://ets-dev.berkeley.edu/news/calcentral-scheduled-upgrade-test-announce-only'
      alert[:timestamp].is_a?(Hash).should be_true
      alert[:timestamp][:epoch].should == 1393257625
    end
    it "handling multi-byte diacritical strings in the reponse" do
      fake_proxy.stub(:xml_source).and_return(xml_multibye_diacriticals)
      alert = fake_proxy.get_latest
      alert[:title].should == '¡El Señor González se zampó un extraño sándwich de vodka y ajo! (¢, ®, ™, ©, •, ÷, –, ¿)'
      alert[:url].should == 'hדג סקרן שט בים מאוכזב ולפתע מצא לו חברה'
      alert[:teaser].should == 'جامع الحروف عند البلغاء يطلق على الكلام المركب من جميع حروف التهجي بدون تكرار أحدها في لفظ واحد، أما في لفظين فهو جائز'
    end
  end

  context "caching successes" do
    include_context 'it writes to the cache'
    it "should write to cache" do
      alert = EtsBlog::Alerts.new({fake:true}).get_latest
    end
  end

  context "caching failures" do
    include_context 'short-lived cache write of NilClass on failures'
    it "should write failure state to cache" do
      fake_proxy.stub(:xml_source).and_return(bad_file_path)
      lambda{
        alert = fake_proxy.get_latest
      }.should_not raise_exception
    end
  end

  context "error handling" do
    it "should raise an exception" do
      fake_proxy.stub(:get_raw_xml).and_return(bad_xml);
      lambda{
        result = fake_proxy.get_alerts
      }.should raise_exception
    end
    it "should log an xml parsing syntax error message" do
      fake_proxy.stub(:get_raw_xml).and_return(bad_xml);
      Rails.logger.should_receive(:error).with(/REXML\:\:ParseException/)
      lambda{
        result = fake_proxy.get_latest
      }.should_not raise_exception
    end
    it "should log a no such file exception" do
      Rails.logger.should_receive(:error).with(/ENOENT No such file or directory/)
      fake_proxy.stub(:xml_source).and_return(bad_file_path)
      fake_proxy.get_latest.should be_nil
    end
    it "should log a SocketError exception" do
      Rails.logger.should_receive(:error).with(/SocketError/).at_least(:once)
      real_failing_proxy.stub(:xml_source).and_return(bad_url)
      real_failing_proxy.get_latest.should be_nil
    end
  end
end
