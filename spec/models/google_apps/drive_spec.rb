describe GoogleApps::DriveList do

  it 'Should return a valid list of drive files' do
    drive_list_proxy = GoogleApps::DriveList.new :fake => true
    expect(drive_list_proxy.class.api).to eq 'drive'
    response = drive_list_proxy.drive_list
    expect(response).to be_an Enumerable
    response.each do |response_page|
      expect(response_page.status).to eq 200
      expect(response_page.data['kind']).to eq 'drive#fileList'
      expect(response_page.data['items']).to be_an Array
    end
  end

end
