describe 'CampusOracle::CourseSections' do

  it 'should correctly translate schedule codes' do
    client = CampusOracle::CourseSections.new({user_id: '300939'})
    expect(client.translate_meeting({ 'meeting_days' => 'S' })).to eq 'Su'
    expect(client.translate_meeting(
      {
        'meeting_days' => 'SMTWTFS',
        'meeting_start_time' => '0900',
        'meeting_start_time_ampm_flag' => 'A',
        'meeting_end_time' => '1100',
        'meeting_end_time_ampm_flag' => 'P'
      })).to eq 'SuMTuWThFSa 9:00A-11:00P'
    expect(client.translate_meeting({ 'meeting_days' => '  T T  ' })).to eq 'TuTh'
    expect(client.translate_meeting(nil)).to be_empty
  end

  describe 'get_section_data' do
    it 'should return pre-populated test sections', :if => Sakai::SakaiData.test_data? do
      client = CampusOracle::CourseSections.new({term_yr: '2013', term_cd: 'D', ccn: '16171'})
      data = client.get_section_data
      expect(data).to_not be_empty
      expect(data[:instructors]).to have(1).items
      expect(data[:instructors][0][:name]).to be_present
      expect(data[:instructors][0][:uid]).to eq '238382'
      expect(data[:instructors][0][:instructor_func]).to eq '1'
      expect(data[:schedules]).to have(2).items
      expect(data[:schedules][0][:schedule]).to eq 'TuTh 2:00P-3:30P'
      expect(data[:schedules][0][:buildingName]).to eq 'WHEELER'
      expect(data[:schedules][1][:schedule]).to eq 'W 4:00P-5:30P'
      expect(data[:schedules][1][:buildingName]).to eq 'DWINELLE'
    end

    it 'should filter out the empty schedules' do
      stubbed_schedules = [
        {'building_name'=>'OFF CAMPUS', 'room_number'=>nil, 'meeting_days'=>'    T', 'meeting_start_time'=>'0330', 'meeting_start_time_ampm_flag'=>'P', 'meeting_end_time'=>'0630', 'meeting_end_time_ampm_flag'=>'P'},
        {'building_name'=>nil, 'room_number'=>nil, 'meeting_days'=>nil, 'meeting_start_time'=>nil, 'meeting_start_time_ampm_flag'=>nil, 'meeting_end_time'=>nil, 'meeting_end_time_ampm_flag'=>nil},
      ]
      client = CampusOracle::CourseSections.new({term_yr: '2013', term_cd: 'D', ccn: '16171'})
      # CampusOracle::Queries.get_section_schedules(@term_yr, @term_cd, @ccn)
      CampusOracle::Queries.should_receive(:get_section_schedules).and_return(stubbed_schedules)
      #allow(CampusOracle::Queries).to receive(:get_section_schedules).and_return(stubbed_schedules)
      result = client.get_section_data

      expect(result).to be_an_instance_of Hash
      expect(result).to have_key :schedules
      expect(result[:schedules]).to have(1).items
    end

    it 'should strip leading zeros from room_number' do
      stubbed_schedules = [
        {'building_name'=>'OFF CAMPUS', 'room_number'=>nil, 'meeting_days'=>'    T', 'meeting_start_time'=>'0330', 'meeting_start_time_ampm_flag'=>'P', 'meeting_end_time'=>'0630', 'meeting_end_time_ampm_flag'=>'P'},
        {'building_name'=>nil, 'room_number'=> '0001', 'meeting_days'=>nil, 'meeting_start_time'=>nil, 'meeting_start_time_ampm_flag'=>nil, 'meeting_end_time'=>nil, 'meeting_end_time_ampm_flag'=>nil},
      ]
      client = CampusOracle::CourseSections.new({term_yr: '2013', term_cd: 'D', ccn: '16171'})
      # CampusOracle::Queries.get_section_schedules(@term_yr, @term_cd, @ccn)
      CampusOracle::Queries.should_receive(:get_section_schedules).and_return(stubbed_schedules)
      #allow(CampusOracle::Queries).to receive(:get_section_schedules).and_return(stubbed_schedules)
      result = client.get_section_data
      expect(result[:schedules][0][:roomNumber]).to be_nil
      expect(result[:schedules][1][:roomNumber]).to eq '1'
    end

  end

end
