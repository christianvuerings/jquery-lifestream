require "spec_helper"

describe Finaid::MyFinAid do
  let!(:oski_uid) { "61889" }
  let!(:non_student_uid) { '212377' }

  let!(:this_term_year) { 2013 }
  let!(:next_term_year) { 2014 }

  let!(:fake_oski_finaid_current){ Finaid::Proxy.new({user_id: oski_uid, term_year: this_term_year,  fake: true }) }
  let!(:fake_oski_finaid_next){ Finaid::Proxy.new({user_id: oski_uid, term_year: next_term_year,  fake: true }) }

  let(:documented_types) { %w(alert financial message info) }

  it { described_class.should respond_to(:append!) }

  describe "expected feed structure on remote proxy" do
    it "should have a successful response code and message" do
      feed = fake_oski_finaid_current.get.try(:[], :body)
      content = Nokogiri::XML(feed) { |config| config.strict }
      content.css('Response Code').text.strip.should == '0000'
      content.css('Response Message').text.strip.should == 'Success'
    end
    it "should have a unsuccessful response code and message for registered test students" , :testext => true, :ignore => true do
      Finaid::Proxy.any_instance.stub(:lookup_student_id).and_return('97450293475029347520394785')
      proxy = Finaid::Proxy.new({user_id: '300849', term_year: this_term_year })
      feed = proxy.get.try(:[], :body)
      content = Nokogiri::XML(feed, &:strict)
      content.css('Response Code').text.should == 'B0023'
      content.css('Response Message').text.strip.should == 'FAILED - BIO record does not exist'
    end
  end

  describe "helper methods" do

    describe '#decode_status' do
      it "should ignore documents with a status of W" do
        status = 'W'
        Rails.logger.should_receive(:info).once.with(/Ignore documents with \"#{status}\" status/)
        lambda {
          result = Finaid::MyFinAid.decode_status('', status)
          result.should be_nil
        }.should_not raise_error
      end
    end

    describe "filtering document entries by date" do
      before {allow(Finaid::TimeRange).to receive(:cutoff_date).and_return(Time.zone.parse("Wed, 27 Feb 2013 16:50:47 PST -08:00"))}
      it "should not include messages that are more than one year old" do
        activities = []
        feed = "<SSIDOC><TrackDocs><Document><Name>Selective Service Verification</Name><Date>2013-03-07</Date></Document><Document><Name>Free Application for Federal Student Aid (FAFSA)</Name><Date>2013-01-28</Date></Document></TrackDocs></SSIDOC>"
        content = Nokogiri::XML(feed, &:strict)
        documents = content.css("TrackDocs Document")
        Rails.logger.should_receive(:info).once.with(/Document is too old to be shown/)
        described_class.append_documents!(documents, "2013-2014", activities)
        activities.length.should == 1
      end
    end

  end

  describe "non 2xx states" do
    let(:activities) { ["some activity"] }

    context "non-student finaid" do
      subject { Finaid::MyFinAid.append!(non_student_uid, activities); activities}

      it { should eq(["some activity"]) }
    end

    context "dead remote proxy (5xx errors)" do
      before(:each) { stub_request(:any, /#{Regexp.quote(Settings.myfinaid_proxy.base_url)}.*/).to_raise(Faraday::Error::ConnectionFailed) }
      after(:each) { WebMock.reset! }

      subject { Finaid::MyFinAid.append!(oski_uid, activities); activities}

      it { should eq(["some activity"]) }
      it "should not write to cache" do
        Rails.cache.should_not_receive(:write)
      end
    end

    context "4xx errors on remote proxy" do
      before(:each) { stub_request(:any, /#{Regexp.quote(Settings.myfinaid_proxy.base_url)}.*/).to_return(:status => 403) }
      after(:each) { WebMock.reset! }

      subject { Finaid::MyFinAid.append!(oski_uid, activities); activities}

      it { should eq(["some activity"]) }
      it "should not write to cache" do
        Rails.cache.should_not_receive(:write)
      end

    end
  end

  describe "2xx states" do
    before do
      allow(Finaid::Proxy).to receive(:new).with({ user_id: oski_uid, term_year: this_term_year }).and_return(fake_oski_finaid_current)
      allow(Finaid::Proxy).to receive(:new).with({ user_id: oski_uid, term_year: next_term_year }).and_return(fake_oski_finaid_next)
    end
    let(:activities) { [] }
    subject do
      Finaid::MyFinAid.append!(oski_uid, activities)
      activities
    end

    context 'when displaying a two-year range' do
      before do
        stub_const('Finaid::TimeRange', double(
          current_years: [this_term_year, next_term_year],
          cutoff_date: Time.zone.parse('2013-04-01')
        ))
      end

      it { should_not be_blank }
      it { subject.length.should eq(26) }
      it { subject.each { |entry| documented_types.should be_include(entry[:type]) } }
      it { subject.each { |entry| entry[:title].should be_present } }
      it { subject.each { |entry| entry[:source_url].should be_present } }
      it { subject.each { |entry| entry[:term_year].should be_present } }
      it { subject.each { |entry| entry[:source].should eq("Financial Aid") } }

      describe "alert types" do
        subject do
          Finaid::MyFinAid.append!(oski_uid, activities)
          activities.select { |entry| entry[:type] == "alert" }
        end

        it { subject.length.should eq(19) }
        it { subject.each { |entry| entry[:date].should be_blank } }
      end
      describe "info types" do
        subject do
          Finaid::MyFinAid.append!(oski_uid, activities)
          activities.select { |entry| entry[:type] == "info" }
        end

        it { subject.length.should eq(2) }
        it { subject.each { |entry| entry[:date].should be_blank } }
      end
      describe "financial types" do
        subject do
          Finaid::MyFinAid.append!(oski_uid, activities)
          activities.select { |entry| entry[:type] == "financial" }
        end

        it { subject.length.should eq(1) }
        it { subject.each { |entry| entry[:title].should be_present } }
      end

      describe "message types" do
        subject do
          Finaid::MyFinAid.append!(oski_uid, activities)
          activities.select { |entry| entry[:type] == "message" }
        end

        it { subject.length.should eq(4) }
        it { subject.each { |entry| entry[:title].should be_present } }
        it "should format dates with the server's timezone configuration and not GMT" do
          a_dated_entry   = subject.find{ |entry| entry[:date].present? }
          # We expect the date information for midnight according to the server's time zone, not midnight GMT
          DateTime.parse(a_dated_entry[:date][:dateTime]).zone.should_not == '+00:00'
        end
      end

      describe "finaid activities" do
        it "should no longer have status messages appended to the title" do
          subject.each{ |entry|
            entry[:title].should_not =~ /[\s\-]+.*action required/
          }
        end

        describe "should have the appropriate status messages" do
          subject do
            Finaid::MyFinAid.append!(oski_uid, activities)
            activities.select { |entry| !entry[:status].nil? }
          end

          it "in at least one faked activity" do
            subject.length.should > 0
          end

          it "for alert types" do
            activity = subject.find{ |entry| entry[:type]=='alert' }
            activity[:status].should == 'Action required, missing document'
          end

          it "for financial types" do
            activity = subject.find{ |entry| entry[:type]=='financial' }
            activity[:status].should == 'No action required, document received not yet reviewed'
          end

          it "for message types" do
            activity = subject.find{ |entry| entry[:type]=='message' }
            activity[:status].should == 'No action required, document reviewed and processed'
          end

        end
      end
    end

    context 'when displaying a one-year range' do
      before do
        stub_const('Finaid::TimeRange', double(
          current_years: [this_term_year],
          cutoff_date: Time.zone.parse('2013-04-01')
        ))
      end
      it { should_not be_blank }
      it { subject.length.should eq(13) }
    end

  end

end
