describe Berkeley::Colleges do

  it 'should look up the College of Engineering' do
    expect(Berkeley::Colleges.get('engr')).to eq 'College of Engineering'
  end

  it 'should return Letters & Science for Grad Div' do
    expect(Berkeley::Colleges.get('grad div')).to eq 'College of Letters & Science'
  end

  it 'should return the abbreviation on a nonexistent college abbv' do
    expect(Berkeley::Colleges.get('Zazzle zotz')).to eq 'Zazzle zotz'
  end

end
