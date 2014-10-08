require "spec_helper"

describe MyAcademics::Semesters do
  context 'when using fake Oracle MV', if: CampusOracle::Queries.test_data? do
    subject { MyAcademics::Semesters.new("300939").merge(@feed ||= {}); @feed[:semesters] }

    describe "should get properly formatted data" do
      it { subject.length.should eq(4) }
      it { subject[0][:name].should eq "Summer 2014" }
      it { subject[0][:termCode].should eq "C" }
      it { subject[0][:termYear].should eq "2014" }
      it { subject[0][:timeBucket].should eq 'future'}
      it { subject[0][:classes].length.should eq 1 }
      it { subject[0][:classes][0][:course_code].should eq "BIOLOGY 1A" }
      it { subject[0][:classes][0][:dept].should eq "BIOLOGY" }
      it { subject[0][:classes][0][:sections].length.should eq 1 }
      it { subject[0][:classes][0][:sections][0][:ccn].should eq "07309" }
      it { subject[0][:classes][0][:sections][0][:waitlistPosition].should eq 42 }
      it { subject[0][:classes][0][:sections][0][:enroll_limit].should eq 5000 }
      it { subject[0][:classes][0][:sections][0][:gradeOption].should eq "P/NP" }
      it { subject[0][:classes][0][:url].should eq '/academics/semester/summer-2014/class/biology-1a' }
      it { subject[1][:name].should eq "Spring 2014" }
      it { subject[1][:timeBucket].should eq 'future'}
      it { subject[2][:name].should eq "Fall 2013"}
      it { subject[2][:timeBucket].should eq 'current' }
      it { subject[3][:name].should eq "Spring 2012" }
      it { subject[3][:timeBucket].should eq 'past' }
      it { subject[2][:classes].length.should eq 2 }
      it { subject[2][:classes][0][:course_code].should eq "BIOLOGY 1A" }
      it { subject[2][:classes][0][:dept].should eq "BIOLOGY" }
      it { subject[2][:classes][0][:sections].length.should eq 2 }
      it { subject[2][:classes][0][:sections][0][:ccn].should eq "07309" }
      it { subject[2][:classes][0][:sections][0][:schedules][0][:schedule].should eq "M 4:00P-5:00P" }
      it { subject[2][:classes][0][:slug].should eq "biology-1a" }
      it { subject[2][:classes][0][:title].should eq "General Biology Lecture" }
      it { subject[2][:classes][0][:url].should eq '/academics/semester/fall-2013/class/biology-1a' }
      it { subject[2][:classes][0][:sections][0][:gradeOption].should eq "Letter" }
      it { subject[2][:classes][0][:sections][0][:instruction_format].should eq "LEC" }
      it { subject[2][:classes][0][:sections][0][:section_number].should eq "003" }
      it { subject[2][:classes][0][:sections][0][:section_label].should eq "LEC 003" }
      it { subject[2][:classes][0][:sections][0][:instructors][0][:name].present?.should be_truthy }
      it { subject[2][:classes][0][:sections][0][:is_primary_section].should be_truthy }
      it { subject[2][:classes][0][:sections][0][:units].to_s.should eq "5.0" }
      it { subject[3][:classes][0][:transcript][0][:grade].should eq "B" }
      it { subject[3][:classes][0][:transcript][0][:units].to_s.should eq "4.0" }
      it { subject[3][:classes][1][:transcript][0][:grade].should eq "C+" }
      it { subject[3][:classes][1][:transcript][0][:units].to_s.should eq "3.0" }
    end

    context 'with constrained semester range' do
      before {Settings.terms.stub(:oldest).and_return('fall-2013')}
      its(:length) {should eq 3}
    end
  end

  describe 'grading_in_progress' do
    let(:uid) {rand(99999)}
    before { allow(Settings.terms).to receive(:fake_now).and_return(fake_now) }
    subject {MyAcademics::Semesters.new(uid).semester_info(2014, 'B')[:gradingInProgress]}
    context 'past semester' do
      let(:fake_now) {DateTime.parse('2014-06-10')}
      it {should be_nil}
    end
    context 'semester just ended' do
      let(:fake_now) {DateTime.parse('2014-05-30')}
      it {should be_truthy}
    end
    context 'current semester' do
      let(:fake_now) {DateTime.parse('2014-05-10')}
      it {should be_nil}
    end
  end

end
