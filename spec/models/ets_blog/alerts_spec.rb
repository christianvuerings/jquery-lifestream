require 'spec_helper'

describe EtsBlog::Alerts do

  let(:fake_proxy) { EtsBlog::Alerts.new({fake: true}) }
  let(:real_failing_proxy) { EtsBlog::Alerts.new({fake: false}) }
  let(:bad_url) { 'http://alsdlksasgflasldsalfjsgj/snjlfdsalsfal/lsadfjfl.xml' }
  let(:bad_file_path) { '/sajdljfsjaslaslsd/garbage/some.xml' }
  let(:bad_xml) { '<xml><chicken>' }
  let(:unexpected_xml) { '<xml><node><chicken>egg</chicken></node></xml>' }
  let(:empty_xml) { '<xml></xml>' }

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
      fake_proxy.get_latest.should be_nil
    end
    it "that receive empty xml data should return nil" do
      fake_proxy.stub(:get_raw_xml).and_return(empty_xml)
      fake_proxy.get_latest.should be_nil
      fake_proxy.stub(:get_raw_xml).and_return(nil)
      fake_proxy.get_latest.should be_nil
      fake_proxy.stub(:get_raw_xml).and_return('')
      fake_proxy.get_latest.should be_nil
    end
  end

  context "successful when" do
    it "Alerts.get_latest returns four fields with values present" do
      alert = fake_proxy.get_latest
      alert.is_a?(Hash)
      alert.count.should == 4
    end
    it "Alerts.get_latest formats and returns the latest single well-formed feed message" do
      alert = fake_proxy.get_latest
      alert[:title].should == 'CalCentral Scheduled Upgrade (Test Announce Only)'
      alert[:teaser].should == 'CalCentral Scheduled Upgrade (Test Announce Only)'
      alert[:url].should == 'http://ets-dev.berkeley.edu/news/calcentral-scheduled-upgrade-test-announce-only'
      alert[:timestamp].is_a?(Hash).should be_true
      alert[:timestamp][:epoch].should == 1393257625
    end
  end

  context "caching" do
    it "should write to cache" do
      Rails.cache.clear
      Rails.cache.should_receive(:write)
      alert = EtsBlog::Alerts.new({fake:true}).get_latest
    end
    it "should not write to cache test" do
      Rails.cache.clear
      fake_proxy.stub(:xml_source).and_return(bad_file_path)
      Rails.cache.should_not_receive(:write)
      lambda{
        alert = fake_proxy.get_latest
      }.should_not raise_exception
    end
    it "should not write to cache" do
      alert = fake_proxy.get_latest
      Rails.cache.should_not_receive(:write)
    end
  end

  context "error handling" do
    it "should raise an exception" do
      fake_proxy.stub(:get_raw_xml).and_return(bad_xml);
      lambda{
        result = fake_proxy.get_alerts
      }.should raise_exception
    end
    it "should log a Nokogiri syntax error message" do
      fake_proxy.stub(:get_raw_xml).and_return(bad_xml);
      Rails.logger.should_receive(:error).with(/Nokogiri\:\:XML\:\:SyntaxError/)
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
      Rails.logger.should_receive(:error).with(/SocketError/)
      real_failing_proxy.stub(:xml_source).and_return(bad_url)
      real_failing_proxy.get_latest.should be_nil
    end
  end
end
