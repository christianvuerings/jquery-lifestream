describe Berkeley::Departments do

  it 'should look up a campus department' do
    expect(Berkeley::Departments.get 'LTSLL').to eq 'Department of Slavic Languages and Literatures'
  end

  it 'should return a concise department name' do
    expect(Berkeley::Departments.get('LTSLL', true)).to eq 'Slavic Languages and Literatures'
    expect(Berkeley::Departments.get('DACED', true)).to eq 'College of Environmental Design'
    expect(Berkeley::Departments.get('EAEDU', true)).to eq 'School of Education'

  end

  it 'should return the key when no value is found' do
    expect(Berkeley::Departments.get 'SKOOL').to eq 'SKOOL'
    expect(Berkeley::Departments.get('SKOOL', true)).to eq 'SKOOL'
  end

end
