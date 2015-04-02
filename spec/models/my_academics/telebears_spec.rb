require 'spec_helper'

describe MyAcademics::Telebears do
  let(:oski_uid){ '61889' }
  let(:non_student_uid) { '212377' }
  let(:student_without_appointments) { '22300939' }
  let(:student_with_odd_xml) { '238382' }

  let!(:fake_oski_feed) { Bearfacts::Telebears.new({:user_id => oski_uid, :fake => true}) }
  let!(:without_appointments_feed) { Bearfacts::Telebears.new({:user_id => student_without_appointments, :fake => true}) }
  let!(:odd_xml_feed) { Bearfacts::Telebears.new({:user_id => student_with_odd_xml, :fake => true}) }

  shared_examples 'empty telebears response' do
    it 'leaves the existing feed alone' do
      expect(subject[:foo]).to eq 'baz'
      expect(subject[:telebears]).to be_empty
    end
  end

  context "student with feed that exists but doesn't have telebearsAppointments element in the XML" do
    before(:each) do
      allow(Bearfacts::Telebears).to receive(:new).and_return(odd_xml_feed)
      allow_any_instance_of(Bearfacts::Telebears).to receive(:lookup_student_id).and_return(student_with_odd_xml)
    end
    subject { MyAcademics::Telebears.new(student_with_odd_xml).merge(@feed ||= {foo: 'baz'}); @feed }

    # Makes sure that the shared example isn't returning false oks due to an empty feed.
    it { Bearfacts::Telebears.new({user_id: student_with_odd_xml}).get.should_not be_blank }
    it_behaves_like 'empty telebears response'
  end

  context "no telebears appointments scheduled" do
    before(:each) do
      allow(Bearfacts::Telebears).to receive(:new).and_return(without_appointments_feed)
      allow_any_instance_of(Bearfacts::Telebears).to receive(:lookup_student_id).and_return(student_without_appointments)
    end
    subject { MyAcademics::Telebears.new(student_without_appointments).merge(@feed ||= {foo: 'baz'}); @feed }

    # Makes sure that the shared example isn't returning false oks due to an empty feed.
    it { Bearfacts::Telebears.new({user_id: student_without_appointments}).get.should_not be_blank }
    it_behaves_like 'empty telebears response'
  end

  context "dead remote proxy (5xx errors)" do
    before(:each) { stub_request(:any, /#{Regexp.quote(Settings.bearfacts_proxy.base_url)}.*/).to_raise(Faraday::Error::ConnectionFailed) }

    subject { MyAcademics::Telebears.new(oski_uid).merge(@feed ||= {foo: 'baz'}); @feed }

    it_behaves_like 'empty telebears response'
  end

  context "4xx response from bearfacts proxy with non-student" do
    before(:each) { Bearfacts::Telebears.any_instance.stub(:get_feed).and_return({}) }

    subject { MyAcademics::Telebears.new(non_student_uid).merge(@feed ||= {foo: 'baz'}); @feed }

    it_behaves_like 'empty telebears response'
  end

  context "2xx responses with fake oski" do
    subject { MyAcademics::Telebears.new(oski_uid).merge(@feed ||= {foo: 'baz'}); @feed }
    before(:each) do
      Bearfacts::Telebears.stub(:new).and_return(fake_oski_feed)
      @fake_feed_body = fake_oski_feed.get[:feed]
    end

    context 'original fake oski feed' do
      it 'contains the expected data' do
        expect(subject[:foo]).to eq 'baz'
        expect(subject[:telebears].length).to eq 1
        telebears = subject[:telebears][0]
        expect(telebears[:term]).to eq 'Fall'
        expect(telebears[:year]).to eq 2013
        expect(telebears[:slug]).to eq 'fall-2013'
        expect(telebears[:advisorCodeRequired][:required]).to be_truthy
        expect(telebears[:advisorCodeRequired][:type]).to eq 'advisor'
        expect(telebears[:phases].length).to eq 2
        expect(telebears[:url]).to be_present
      end

      it 'uses the server timezone setting' do
        phase_one = subject[:telebears][0][:phases][0]
        expect(phase_one[:startTime][:epoch]).to eq 1365438600
        expect(phase_one[:endTime][:epoch]).to eq 1365525000
        [:startTime, :endTime].each do |key|
          time_string = phase_one[key][:dateTime]
          tz_from_string = DateTime.parse(time_string).rfc3339
          server_enforced_tz = Time.zone.parse(time_string).to_datetime.rfc3339
          expect(tz_from_string).to eq(server_enforced_tz)
        end
      end
    end

    describe 'advisorCodeRequired translation' do
      before do
        @fake_feed_body['telebearsAppointment'].unwrap['authReleaseCode'] = fake_code
        allow_any_instance_of(Bearfacts::Telebears).to receive(:get).and_return({feed: @fake_feed_body})
      end
      let(:advisor_code_required) { subject[:telebears][0][:advisorCodeRequired] }
      context 'default' do
        let(:fake_code) {'P'}
        it 'describes the code' do
          expect(advisor_code_required[:required]).to eq false
          expect(advisor_code_required[:type]).to eq 'none'
        end
      end
      context 'CalSO' do
        let(:fake_code) {'C'}
        it 'describes the code' do
          expect(advisor_code_required[:required]).to eq true
          expect(advisor_code_required[:type]).to eq 'calso'
        end
      end
      context 'required' do
        let(:fake_code) {'A'}
        it 'describes the code' do
          expect(advisor_code_required[:required]).to eq true
          expect(advisor_code_required[:type]).to eq 'advisor'
        end
      end
      context 'access revoked' do
        let(:fake_code) {'N'}
        it 'describes the code' do
          expect(advisor_code_required[:required]).to eq true
          expect(advisor_code_required[:type]).to eq 'revoked'
        end
      end
      context 'unknown code' do
        let(:fake_code) {'foo'}
        it 'returns the default' do
          expect(Rails.logger).to receive(:warn).at_least(1).times
          expect(advisor_code_required[:required]).to eq false
          expect(advisor_code_required[:type]).to eq 'none'
        end
      end
    end
  end

  context 'before the first day of classes in what BearFacts considers the Current Term' do
    let(:fake_fall_term) { double({
        code: 'D',
        year: 2014,
        classes_start: Time.zone.today.in_time_zone.to_datetime.advance(days:5),
        sis_term_status: 'CT'
      }) }
    let(:fake_summer_term) { double({
        code: 'B',
        year: 2014,
        sis_term_status: 'CS'
      }) }
    let(:fake_terms) { double({
        current: fake_summer_term,
        campus: {'summer-2014' => fake_summer_term, 'fall-2014' => fake_fall_term}
      }) }
    before do
      allow(Settings.bearfacts_proxy).to receive(:fake).at_least(:once).and_return(true)
      allow(Berkeley::Terms).to receive(:fetch).at_least(:once).and_return(fake_terms)
    end
    it 'includes Current Term appointments as well as Future Term' do
      feed = {}
      MyAcademics::Telebears.new(oski_uid).merge(feed)
      telebears_list = feed[:telebears]
      expect(telebears_list.length).to eq 2
      expect(telebears_list[0][:term]).to eq 'Spring'
      expect(telebears_list[0][:phases].length).to eq 1
      expect(telebears_list[1][:term]).to eq 'Fall'
      expect(telebears_list[1][:phases].length).to eq 2
    end
  end

end
