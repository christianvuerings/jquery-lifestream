describe Canvas::Groups do

  it 'should get groups as known member' do
    groups = Canvas::Groups.new(user_id: @user_id).groups
    expect(groups[:body]).to_not be_empty
    expect(groups[:body][0]['name']).to be_present
  end

end
