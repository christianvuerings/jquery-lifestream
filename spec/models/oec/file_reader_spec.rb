describe Oec::FileReader do

  context 'reading the courses file and returning ccns' do
    subject { Oec::FileReader.new 'fixtures/oec/courses.csv' }
    it {
      subject.ccns.should contain_exactly(87672, 54432, 87675, 54441, 87690, 72198, 87693, 2567, 87673, 72199, 87691)
    }
  end

end
