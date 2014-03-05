require 'spec_helper'

describe AppAlertsProxy do

  let!(:fake_proxy) { AppAlertsProxy.new({fake: true}) }

  context "failures" do
    before(:each){
      @result = []
    }
    it "not finding fake xml feed should return nil and log rescued exceptions as errors" do
      fake_proxy.stub(:get_fetch_url).and_return('/sajdljfsjaslaslsd/garbage/some.xml')
      Rails.logger.should_receive(:error).once.with(/ENOENT.+No such file or directory/)
      @result = fake_proxy.get_latest
      @result.should be_nil
    end
    it "not finding real feed urls should return nil and log rescued exceptions as errors" do
      failing_proxy = AppAlertsProxy.new({fake: false})
      failing_proxy.stub(:get_fetch_url).and_return('http://alsdlksasgflasldsalfjsgj/snjlfdsalsfal/lsadfjfl.xml')
      Rails.logger.should_receive(:error).once.with(/Http error/)
      @result = failing_proxy.get_latest
      @result.should be_nil
    end
    it "parsing invalid xml should return nil and log and rescue exception as error" do
      AppAlertsProxy.any_instance.stub(:fetch_xml_content).and_return("<xml><chicken>")
      Rails.logger.should_receive(:error).once.with(/Error parsing XML data/)
      @result = fake_proxy.get_latest
      @result.should be_nil
    end
    it "parsing unexpected xml data structures should return empty hash values" do
      AppAlertsProxy.any_instance.stub(:fetch_xml_content).and_return("<xml><node><thing_1>CalCentral Emergency Outage</thing_1><thing_2>1393620301</thing_2></node></xml>")
      @result = fake_proxy.get_latest
      [:title, :teaser, :url].each{|p| @result[p].present?.should be_false }
      @result[:timestamp].class.should == Hash
      @result[:timestamp][:epoch].should == 0
    end
  end

  context "successful" do
    before(:each){
      @result = nil
    }
    it "AppAlertsProxy.get_latest should have four fields with values present" do
      alert = fake_proxy.get_latest
      alert.select{|k,v| v.present? }.count.should == 4
    end
    it "AppAlertsProxy.get_latest should format and return the latest single well-formed feed message" do
      alert = fake_proxy.get_latest
      alert.class.should == Hash
      alert.count.should == 4
      alert[:title].should == 'CalCentral Scheduled Upgrade (Test Announce Only)'
      alert[:teaser].should == 'CalCentral Scheduled Upgrade (Test Announce Only)'
      alert[:url].should == 'http://ets-dev.berkeley.edu/news/calcentral-scheduled-upgrade-test-announce-only'
      alert[:timestamp].class.should == Hash
      alert[:timestamp][:epoch].should == 1393257625
    end
  end

  context "caching" do
    it "should write to cache" do
      Rails.cache.clear
      Rails.cache.should_receive(:write)
      alert = AppAlertsProxy.new({fake:true}).get_latest
    end
    it "should not write to cache" do
      alert = fake_proxy.get_latest
      Rails.cache.should_not_receive(:write)
    end
  end

end
