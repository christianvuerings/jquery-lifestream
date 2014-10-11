describe Oec::FileReader do

  context 'reading the courses file and returning ccns' do
    subject { Oec::FileReader.new 'fixtures/oec/courses.csv' }
    it {
      subject.ccns.should_not be_blank
      subject.ccns.should == [87672, 54432, 87675, 54441, 87690, 72198, 87693, 2567, 54432, 87672, 54441, 87675, 72198, 87690]
    }
  end

end
