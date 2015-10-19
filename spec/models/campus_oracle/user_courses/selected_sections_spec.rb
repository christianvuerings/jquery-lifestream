describe CampusOracle::UserCourses::SelectedSections do

  it 'mimics normal My Academics feed', :if => CampusOracle::Connection.test_data? do
    client = CampusOracle::UserCourses::SelectedSections.new({user_id: '238382'})
    courses = client.get_selected_sections(2013, 'D', [7309])
    sections = courses['2013-D'].first[:sections]
    expect(sections.size).to eq 1
    expect(sections.first[:ccn]).to eq '07309'
    expect(sections.first[:schedules].size).to eq 2
  end

end
