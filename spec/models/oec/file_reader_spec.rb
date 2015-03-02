describe Oec::FileReader do

  context 'reading the courses file and returning ccns' do
    subject { Oec::FileReader.new 'fixtures/oec/courses.csv' }
    it {
      subject.ccn_set.should contain_exactly(87672, 54432, 87675, 54441, 87690, 72198, 87693, 2567, 87673, 72199, 87691, 71523)
      subject.annotated_ccn_hash[11577].should contain_exactly('CHEM', 'MCB')
      subject.annotated_ccn_hash[18215].should contain_exactly('A', 'B')
      subject.annotated_ccn_hash[22729].should contain_exactly('A', 'B')
      subject.annotated_ccn_hash[71523].should contain_exactly 'GSI'
      subject.annotated_ccn_hash[87693].should contain_exactly 'GSI'
    }
  end

end
