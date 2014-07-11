require 'spec_helper'

describe Calendar::Exporter do

  describe '#ship_entries', ignore: true do
    context 'when shipping entries to Google', if: Calendar::Queries.test_data? do
      before do
        user = Calendar::User.new
        user.uid = '300939'
        user.alternate_email = 'ctweney@testg.berkeley.edu.test-google-a.com'
        user.save
      end
      let!(:processor) { Calendar::Preprocessor.new }
      let!(:exporter) { Calendar::Exporter.new }
      subject { exporter.ship_entries(processor.get_entries) }
      it 'should have sent entries to Google' do
        expect(subject).to be_present
        expect(subject[0].event_id).to be_present
        p "Results = #{subject.inspect} "
      end
    end
  end

end
