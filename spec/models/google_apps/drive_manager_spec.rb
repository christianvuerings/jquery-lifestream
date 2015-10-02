describe GoogleApps::DriveManager do

  context '#real', testext: true, :order => :defined do

    before(:all) do
      settings = Settings.oec.google.marshal_dump
      @drive = GoogleApps::DriveManager.new Settings.oec.google.uid, settings
      now = DateTime.now.strftime('%m/%d/%Y at %I:%M%p')
      title = "GoogleDriveInsert tested on #{now}"
      csv_file = 'fixtures/oec_legacy/courses.csv'
      text_file = 'fixtures/jms_recordings/ist_jms.txt'
      @folder = @drive.create_folder title
      @csv_filename = "CSV file, #{now}"
      @csv_file = @drive.upload_file(@csv_filename, 'CSV file description', @folder.id, 'text/csv', csv_file)
      @text_filename = "Text file, #{now}"
      @text_file = @drive.upload_file(@text_filename, 'Text file description', @folder.id, 'text/plain', text_file)
    end

    after(:all) do
      @drive.trash_item(@folder, permanently_delete: true) if @folder
    end

    it 'should find folder by name' do
      result = @drive.find_folders_by_title @folder.title
      expect(result).to_not be_nil
      expect(result).to have(1).item
      expect(result[0].id).to eq @folder.id
      expect(result[0].title).to eq @folder.title
    end

    it 'should find all files in folder' do
      items = @drive.get_items_in_folder @folder.id
      expect(items).to have(2).items
      expect([items[0].title, items[1].title]).to contain_exactly(@csv_filename, @text_filename)
    end

    it 'should find all CSV files in folder' do
      items = @drive.get_items_in_folder(@folder.id, 'text/csv')
      expect(items).to have(1).item
      expect(items[0].title).to eq @csv_filename
    end

    it 'should copy CSV file to a new folder without modifying original' do
      copy = @drive.copy_item_to_folder(@csv_file, 'root')

      copied_items = @drive.find_items_by_title(@csv_filename, parent_id: 'root')
      expect(copied_items).to have(1).item
      expect(copied_items[0].id).to eq copy.id
      expect(copied_items[0].title).to eq @csv_filename

      original_items = @drive.find_items_by_title(@csv_filename, parent_id: @folder.id)
      expect(original_items).to have(1).item
      expect(original_items[0].title).to eq @csv_filename

      @drive.trash_item(copy, permanently_delete: true)
    end

    it 'should find CSV file' do
      items = @drive.find_items_by_title(@csv_filename, parent_id: @folder.id)
      expect(items).to_not be_nil
      expect(items).to have(1).item
      item = items[0]
      expect(item).to_not be_nil
      expect(item.title).to eq @csv_filename
      expect(item.mimeType).to eq 'text/csv'
      expect(item.description).to_not be_nil
      @drive.trash_item(item, permanently_delete: true)
      # Verify not found after trashing
      items = @drive.find_items_by_title(@csv_filename, parent_id: @folder.id)
      expect(items).to be_empty
    end

  end
end
