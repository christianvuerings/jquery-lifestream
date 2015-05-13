describe Canvas::WebcastEligibleCourses do

  context 'fake data' do

    subject { Canvas::WebcastEligibleCourses.new(%w(TERM:2014-D TERM:2015-B), {:user_id => @user_id, fake: true}).fetch }

    context 'csv files exist' do
      before do
        report_fall_2014 = CSV.read('fixtures/webcast/canvas-sections-report_2014-D.csv', {headers: true})
        allow_any_instance_of(Canvas::Report).to receive(:get_account_csv).with('provisioning', 'sections', 'TERM:2014-D').and_return report_fall_2014
        report_spring_2015 = CSV.read('fixtures/webcast/canvas-sections-report_2015-B.csv', {headers: true})
        allow_any_instance_of(Canvas::Report).to receive(:get_account_csv).with('provisioning', 'sections', 'TERM:2015-B').and_return report_spring_2015
      end

      it 'should return official courses per configured account_id' do
        expect(subject).to have_at_least(1).items
      end

      it 'should flag section when CCN is eligible for webcast sign up' do
        # Webcast sign-up is active
        expect(subject).to have(2).items
        expect(subject['1336653']).to_not be_nil
        sign_up_eligible = subject['1336761']
        expect(sign_up_eligible).to_not be_nil
        expect(sign_up_eligible).to have(1).items
        section = sign_up_eligible.first
        expect(section[:term_yr].to_i).to eq 2015
        expect(section[:term_cd]).to eq 'B'
        expect(section[:ccn].to_i).to eq 5916
        expect(section[:has_webcast_recordings]).to be false
        expect(section[:is_webcast_eligible]).to be true
      end

      it 'should not flag sign-up eligible sections when is_sign_up_active = false' do
        allow_any_instance_of(Webcast::SystemStatus).to receive(:get).and_return({ 'is_sign_up_active' => false })
        # Although is_sign_up_active = false, we still serve list of sections webcast
        expect(subject).to have(1).items
        course = subject['1336653']
        expect(course).to_not be_nil
        expect(course).to have(1).items
        section = course.first
        expect(section[:term_yr].to_i).to eq 2015
        expect(section[:term_cd]).to eq 'B'
        expect(section[:ccn].to_i).to eq 51990
        expect(section[:has_webcast_recordings]).to be true
        expect(section[:is_webcast_eligible]).to be false
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
