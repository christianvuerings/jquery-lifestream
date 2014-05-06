require 'spec_helper'

describe Finaid::TimeRange do
  before {allow(Settings.terms).to receive(:fake_now).and_return(fake_now)}

  describe '#current_years' do
    before do
      allow(Finaid::FinAidYear).to receive(:get_upcoming_start_date) do |year|
        case year
          when 2013 then Date.new(2013, 3, 28)
          when 2014 then Date.new(2014, 3, 29)
          else nil
        end
      end
    end
    subject {Finaid::TimeRange.current_years}
    context 'early in year' do
      let(:fake_now) {DateTime.parse('2013-02-28')}
      it { should eq [2013] }
    end
    context 'during summer session' do
      let(:fake_now) {DateTime.parse('2013-06-16')}
      it { should eq [2013, 2014] }
    end
    context 'after summer session' do
      let(:fake_now) {DateTime.parse('2013-08-30')}
      it { should eq [2014] }
    end
    context 'close to last year in DB' do
      let(:fake_now) {DateTime.parse('2014-04-01')}
      it 'logs a fatal error' do
        class_logger = double
        expect(class_logger).to receive(:fatal).with(/2015/)
        allow(Finaid::TimeRange).to receive(:logger).and_return(class_logger)
        expect(subject).to eq [2014, 2015]
      end
    end
  end

  describe '#cutoff_date' do
    subject {Finaid::TimeRange.cutoff_date}
    let(:fake_now) {DateTime.parse('2013-06-16')}
    let(:last_year) {fake_now.advance(years: -1)}
    it {should eq last_year}
  end

end
