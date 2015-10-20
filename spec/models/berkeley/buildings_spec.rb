describe Berkeley::Buildings do

  it 'should look up Hearst Mining' do
    Berkeley::Buildings.get('hearst min')['display'].should == 'Hearst Memorial Mining Building'
  end

  it 'should look up Lothlorien with a room number' do
    Berkeley::Buildings.get('100 TEMP86')['display'].should == 'Lothlorien Hall'
    Berkeley::Buildings.get('100 TEMP86')['roomNumber'].should == '100'
  end

  it 'should look up 2224 PIEDMNT with a room number' do
    Berkeley::Buildings.get('100 2224 PIEDMNT')['display'].should == '2224 Piedmont'
    Berkeley::Buildings.get('100 2224 PIEDMNT')['roomNumber'].should == '100'
  end

  it 'should look up 2224 PIEDMNT without a room number' do
    Berkeley::Buildings.get('2224 PIEDMNT')['display'].should == '2224 Piedmont'
    Berkeley::Buildings.get('2224 PIEDMNT')['roomNumber'].should be_nil
  end

  it 'should look up 220 HEARST GYM (Instructor: SHABEL, A B) with a room number and remove the instructor' do
    Berkeley::Buildings.get('220 HEARST GYM (Instructor: SHABEL, A B)')['display'].should == 'Hearst Gym'
    Berkeley::Buildings.get('220 HEARST GYM (Instructor: SHABEL, A B)')['roomNumber'].should == '220'
  end

  it 'should return nil on a nonexistent building' do
    Berkeley::Buildings.get('Barad Dur').should be_nil
  end

end
