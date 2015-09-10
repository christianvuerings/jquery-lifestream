describe Berkeley::Departments do

  it 'should look up a campus department' do
    expected = 'Department of Slavic Languages and Literatures'
    dept_code = 'LTSLL'
    expect(Berkeley::Departments.get(dept_code)).to eq expected
    expect(Berkeley::Departments.get(dept_code, concise: false)).to eq expected
  end

  it 'should return a concise department name' do
    expect(Berkeley::Departments.get('LTSLL', concise: true)).to eq 'Slavic Languages and Literatures'
    expect(Berkeley::Departments.get('DACED', concise: true)).to eq 'Environmental Design'
    expect(Berkeley::Departments.get('EAEDU', concise: true)).to eq 'Education'
    expect(Berkeley::Departments.get('BMCCB', concise: true)).to eq 'Computational Biology'
    expect(Berkeley::Departments.get('QHUIS', concise: true)).to eq 'Undergraduate and Interdisciplinary Studies'
    # We do not remove 'History of' because the resulting 'Art' would be misleading
    expect(Berkeley::Departments.get('HARTH', concise: true)).to eq 'History of Art'
    expect(Berkeley::Departments.get('IQBBB', concise: true)).to eq 'QB3'
    expect(Berkeley::Departments.get('QLROT', concise: true)).to eq 'Military Affairs'
    expect(Berkeley::Departments.get('QKCWP', concise: true)).to eq 'College Writing'
    expect(Berkeley::Departments.get('QIIAS', concise: true)).to eq 'International and Area Studies'
  end

  it 'should never trim \'Haas School of Business\' and similar' do
    dept_code = 'BAHSB'
    expected = 'Haas School of Business'
    expect(Berkeley::Departments.get(dept_code)).to eq expected
    expect(Berkeley::Departments.get(dept_code, concise: true)).to eq expected
  end

  it 'should return the key when no value is found' do
    expect(Berkeley::Departments.get 'SKOOL').to eq 'SKOOL'
    expect(Berkeley::Departments.get('SKOOL', concise: true)).to eq 'SKOOL'
  end

end
