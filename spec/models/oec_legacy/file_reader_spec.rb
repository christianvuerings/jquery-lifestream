describe OecLegacy::FileReader do

  let!(:file_reader) { OecLegacy::FileReader.new 'fixtures/oec_legacy/courses.csv' }
  let!(:ccn_set) { file_reader.ccn_set }
  let!(:annotated_ccn_hash) { file_reader.annotated_ccn_hash }

  it 'should not put annotated CCNs in ccn_set' do
    ccn_set.should contain_exactly(87672, 54432, 87675, 54441, 87690, 72198, 87693, 2567, 87673, 72199, 87691, 71523)
  end

  it 'should only put annotated CCNs in annotated_ccn_hash' do
    annotated_ccn_hash.keys.should contain_exactly(11577, 18215, 22729, 71523, 87693)
  end

  it 'should recognize GSI annotations' do
    annotated_ccn_hash[71523].should contain_exactly 'GSI'
    annotated_ccn_hash[87693].should contain_exactly 'GSI'
  end

  it 'should recognize CHEM and MCB annotations' do
    annotated_ccn_hash[11577].should contain_exactly('CHEM', 'MCB')
  end

  it 'should recognize A and B annotations' do
    annotated_ccn_hash[18215].should contain_exactly('A', 'B')
    annotated_ccn_hash[22729].should contain_exactly('A', 'B')
  end

end
