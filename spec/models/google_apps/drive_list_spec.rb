describe 'GoogleDriveList' do

  after { WebMock.reset! }

  context 'get list', :testext => true do
    let(:drive_list_proxy) {
      proxy_opts = {
        :fake => false,
        :access_token => Settings.google_proxy.test_user_access_token,
        :refresh_token => Settings.google_proxy.test_user_refresh_token,
        :expiration_time => 0
      }
      GoogleApps::DriveList.new proxy_opts
    }

    it 'should get real drive docs list using the Tammi account' do
      response = drive_list_proxy.drive_list
      expect(response).to be_an Enumerable
      # Should help raise concerns if recordings goes wrong
      response.each do |response_page|
        expect(response_page.status).to eq 200
        expect(response_page.data['kind']).to eq 'drive#fileList'
        expect(response_page.data['items']).to be_an Array
      end
    end

    it 'should respect criteria when searching by title' do
      optional_params = { :q => 'title contains \'Assignment\'' }
      response = drive_list_proxy.drive_list optional_params
      response.each do |response_page|
        expect(response_page.status).to eq 200
        items = response_page.data['items']
        expect(items).to have_at_least(2).items
      end
    end

    it 'should list contents of directory' do
      title = 'Research'
      response = drive_list_proxy.drive_list({ :q => "title = '#{title}'" })
      first = response.first
      expect(first).to_not be_nil
      search_result = first.data['items'][0]
      expect(search_result['title']).to eq title
      folder_id = search_result['id']
      expect(folder_id).to_not be_nil

      response = drive_list_proxy.drive_list({ :q => "'#{folder_id}' in parents" })
      response.each do |response_page|
        expect(response_page).to_not be_nil
        items = response_page.data['items']
        expect(items).to have_at_least(1).item
        expect(items[0]['title']).to_not be_nil
      end
    end
  end

end
