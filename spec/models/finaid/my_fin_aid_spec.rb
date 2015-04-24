require 'spec_helper'

describe Finaid::MyFinAid do
  let!(:oski_uid) { '61889' }
  let!(:non_student_uid) { '212377' }

  let!(:this_term_year) { 2013 }
  let!(:next_term_year) { 2014 }

  let!(:fake_oski_finaid_current) { Finaid::Proxy.new({user_id: oski_uid, term_year: this_term_year, fake: true}) }
  let!(:fake_oski_finaid_next) { Finaid::Proxy.new({user_id: oski_uid, term_year: next_term_year, fake: true}) }

  let(:documented_types) { %w(alert financial message info) }

  describe 'expected feed structure on remote proxy' do
    context 'when student is Oski' do
      let!(:feed) { fake_oski_finaid_current.get }

      it 'should have a successful response code and message' do
        expect(feed['SSIDOC']['Response']['Code'].to_text).to eq '0000'
        expect(feed['SSIDOC']['Response']['Message'].to_text).to eq 'Success'
      end

      it 'should include multiple documents and diagnostics' do
        expect(feed['SSIDOC']['FALifecycle']['TrackData']['TrackDocs']['Document'].to_a.count).to be > 1
        expect(feed['SSIDOC']['FALifecycle']['DiagnosticData']['Diagnostic'].to_a.count).to be > 1
      end
    end

    context 'when student is a registered test student', :testext => true do
      before { allow_any_instance_of(Finaid::Proxy).to receive(:lookup_student_id).and_return('97450293475029347520394785') }
      let!(:feed) { Finaid::Proxy.new({user_id: '300849', term_year: this_term_year, fake: false}).get }

      it 'should have a unsuccessful response code and message' do
        expect(feed['SSIDOC']['Response']['Code'].to_text).to eq 'B0023'
        expect(feed['SSIDOC']['Response']['Message'].to_text).to eq 'FAILED - BIO record does not exist'
      end
    end
  end

  describe 'helper methods' do

    subject { Finaid::MyFinAid.new(nil) }

    describe '#decode_status' do
      it 'should ignore documents with a status of W' do
        status = 'W'
        Rails.logger.should_receive(:info).once.with(/Ignore documents with \"#{status}\" status/)
        lambda {
          result = {}
          subject.append_status('', status, result)
          result.should == {}
        }.should_not raise_error
      end
    end

    describe 'filtering document entries by date' do
      before { allow(Finaid::TimeRange).to receive(:cutoff_date).and_return(Time.zone.parse('Wed, 27 Feb 2013 16:50:47 PST -08:00')) }
      it 'should not include messages that are more than one year old' do
        activities = []
        feed_xml = '<SSIDOC><TrackDocs><Document><Name>Selective Service Verification</Name><Date>2013-03-07</Date></Document><Document><Name>Free Application for Federal Student Aid (FAFSA)</Name><Date>2013-01-28</Date></Document></TrackDocs></SSIDOC>'
        feed = FeedWrapper.new(MultiXml.parse(feed_xml))
        documents = feed['SSIDOC']['TrackDocs']['Document'].as_collection

        Rails.logger.should_receive(:info).once.with(/Document is too old to be shown/)
        subject.append_documents!(documents, '2013-2014', activities)
        activities.length.should == 1
      end
    end

  end

  describe 'non 2xx states' do
    before { Settings.myfinaid_proxy.fake = false }
    after { Settings.myfinaid_proxy.fake = true }
    let(:activities) { ['some activity'] }

    context 'non-student finaid' do
      subject { Finaid::MyFinAid.new(non_student_uid).append!(activities); activities }
      it { should eq(['some activity']) }
    end

    context 'student finaid with remote problems' do

      subject { Finaid::MyFinAid.new(oski_uid).append!(activities); activities }

      context 'dead remote proxy (5xx errors)' do
        before(:each) { stub_request(:any, /#{Regexp.quote(Settings.myfinaid_proxy.base_url)}.*/).to_raise(Faraday::Error::ConnectionFailed) }
        after(:each) { WebMock.reset! }

        it { should eq(['some activity']) }
        it 'should not write to cache' do
          Rails.cache.should_not_receive(:write)
        end
      end

      context '4xx errors on remote proxy' do
        before(:each) { stub_request(:any, /#{Regexp.quote(Settings.myfinaid_proxy.base_url)}.*/).to_return(:status => 403) }
        after(:each) { WebMock.reset! }

        it { should eq(['some activity']) }
        it 'should not write to cache' do
          Rails.cache.should_not_receive(:write)
        end

      end

    end
  end

  describe '2xx states' do
    let!(:activities) { [] }
    before do
      allow(Finaid::Proxy).to receive(:new).with({user_id: oski_uid, term_year: this_term_year}).and_return(fake_oski_finaid_current)
      allow(Finaid::Proxy).to receive(:new).with({user_id: oski_uid, term_year: next_term_year}).and_return(fake_oski_finaid_next)
    end

    subject do
      activities
    end

    context 'when displaying a two-year range' do
      before do
        stub_const('Finaid::TimeRange', double(
          current_years: [this_term_year, next_term_year],
          cutoff_date: Time.zone.parse('2013-04-01')
        ))
        Finaid::MyFinAid.new(oski_uid).append!(activities)
      end

      it { should_not be_blank }
      if Settings.myfinaid_proxy.fake
        it { subject.length.should eq(28) }
      end
      it { subject.each { |entry| documented_types.should be_include(entry[:type]) } }
      it { subject.each { |entry| entry[:title].should be_present } }
      it { subject.each { |entry| entry[:sourceUrl].should be_present } }
      it { subject.each { |entry| entry[:termYear].should be_present } }
      it { subject.each { |entry| entry[:source].should eq('Financial Aid') } }

      describe 'alert types' do
        subject do
          activities.select { |entry| entry[:type] == 'alert' }
        end

        if Settings.myfinaid_proxy.fake
          it { subject.length.should eq(21) }
        end
      end

      describe 'info types' do
        subject do
          activities.select { |entry| entry[:type] == 'info' }
        end

        it { subject.length.should eq(2) }
        it { subject.each { |entry| entry[:date].should be_blank } }
      end
      describe 'financial types' do
        subject do
          activities.select { |entry| entry[:type] == 'financial' }
        end

        if Settings.myfinaid_proxy.fake
          it { subject.length.should eq(2) }
        end
        it { subject.each { |entry| entry[:title].should be_present } }
      end

      describe 'message types' do
        subject do
          activities.select { |entry| entry[:type] == 'message' }
        end

        it { subject.length.should eq(3) }
        it { subject.each { |entry| entry[:title].should be_present } }
        it 'should format dates with the servers timezone configuration and not GMT ' do
          a_dated_entry = subject.find { |entry| entry[:date].present? }
          # We expect the date information for midnight according to the server' s time zone, not midnight GMT
          DateTime.parse(a_dated_entry[:date][:dateTime]).zone.should_not == '+00:00'
        end
      end

      describe 'finaid activities' do
        it 'should no longer have status messages appended to the title' do
          subject.each { |entry|
            entry[:title].should_not =~ /[\s\-]+.*action required/
          }
        end

        describe 'should have the appropriate status messages' do
          subject do
            activities.select { |entry| !entry[:status].nil? }
          end

          it 'in at least one faked activity' do
            subject.length.should > 0
          end

          it 'for financial types' do
            activity = subject.find { |entry| entry[:type]=='financial' }
            activity[:status].should == 'No action required, document received not yet reviewed'
          end

          it 'for message types' do
            activity = subject.find { |entry| entry[:type]=='message' }
            activity[:status].should == 'No action required, document reviewed and processed'
          end

        end
      end

      if Settings.myfinaid_proxy.fake
        context 'testing specific status code handling' do
          context 'status-Q documents' do
            subject do
              activities.select { |entry| entry[:type] == 'alert' && entry[:title] == 'Social Security Number Certification' }
            end
            it { subject.length.should eq(2) }
            it { subject[0][:date].should eq '' }
            it { subject[0][:status].should eq 'Action required, missing document' }
          end
          context 'status-N documents' do
            subject do
              activities.select { |entry| entry[:type] == 'financial' && entry[:title] == 'FAFSA Income or Asset Change' }
            end
            it { subject.length.should eq(2) }
            it { subject[0][:date].should_not be_nil }
            it { subject[0][:status].should eq 'No action required, document received not yet reviewed' }
          end
          context 'status-P documents' do
            subject do
              activities.select { |entry| entry[:type] == 'message' && entry[:title] == 'Budget Appeal' }
            end
            it { subject.length.should eq(1) }
            it { subject[0][:date].should_not be_nil }
            it { subject[0][:status].should eq 'No action required, document reviewed and processed' }
          end
          context 'status-R documents' do
            subject do
              activities.select { |entry| entry[:type] == 'alert' && entry[:title] == 'THIRD PARTY AUTHORIZATION - CF - CF' }
            end
            it { subject.length.should eq(1) }
            it { subject[0][:date].should_not be_nil }
            it { subject[0][:status].should eq 'Action required, document received and returned' }
          end
          context 'status-I documents' do
            subject do
              activities.select { |entry| entry[:type] == 'alert' && entry[:title] == 'Verification Dependent' }
            end
            it { subject.length.should eq(2) }
            it { subject[0][:date].should_not be_nil }
            it { subject[0][:status].should eq 'Action required, document received and incomplete' }
          end
          context 'status-U documents' do
            subject do
              activities.select { |entry| entry[:type] == 'alert' && entry[:title] == 'Selective Service Verification - CF' }
            end
            it { subject.length.should eq(1) }
            it { subject[0][:date].should_not be_nil }
            it { subject[0][:status].should eq 'Action required, document received and unsigned' }
          end
          context 'status-X documents' do
            subject do
              activities.select { |entry| entry[:type] == 'alert' && entry[:title] == 'U.S. Citizenship Confirmation - CF' }
            end
            it { subject.length.should eq(1) }
            it { subject[0][:date].should_not be_nil }
            it { subject[0][:status].should eq 'Action required, document received and on hold' }
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
        Finaid::MyFinAid.new(oski_uid).append!(activities)
      end
      it { should_not be_blank }
      if Settings.myfinaid_proxy.fake
        it { subject.length.should eq(15) }
      end
    end

  end
end
