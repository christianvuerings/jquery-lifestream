describe Canvas::WebcastEligibleCourses do

  context 'fake data' do

    subject { Canvas::WebcastEligibleCourses.new(%w(TERM:2014-B TERM:2014-D) ,{:user_id => @user_id, fake: true}).fetch }

    context 'csv files exist' do
      before do
        report_spring_2014 = CSV.read('fixtures/webcast/canvas-sections-report_2014-B.csv', {headers: true})
        allow_any_instance_of(Canvas::Report).to receive(:get_account_csv).with('provisioning', 'sections', 'TERM:2014-B').and_return report_spring_2014
        report_fall_2014 = CSV.read('fixtures/webcast/canvas-sections-report_2014-D.csv', {headers: true})
        allow_any_instance_of(Canvas::Report).to receive(:get_account_csv).with('provisioning', 'sections', 'TERM:2014-D').and_return report_fall_2014
      end
      it 'should return official courses per configured account_id' do
        expect(subject).to have_at_least(1).items
      end
    end

    context 'no csv files' do
      before do
        allow_any_instance_of(Canvas::Report).to receive(:get_account_csv).and_return []
      end
      it 'should return nothing when csv is empty' do
        expect(subject).to be_empty
      end
    end

  end
end
