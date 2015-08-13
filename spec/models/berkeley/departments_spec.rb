describe Berkeley::Departments do

  it 'should look up a campus department' do
    expect(Berkeley::Departments.get 'LTSLL').to eq 'Department of Slavic Languages and Literatures'
  end

  it 'should return the key when no value is found' do
    expect(Berkeley::Departments.get 'SKOOL').to eq 'SKOOL'
  end

end
