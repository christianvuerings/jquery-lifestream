describe GoogleApps::SheetsManager do

  context '#real', testext: true, :order => :defined do

    before(:all) do
      @sheets = GoogleApps::SheetsManager.new GoogleApps::CredentialStore.new(app_name: 'oec')
      now = DateTime.now.strftime('%m/%d/%Y at %I:%M%p')
      @folder = @sheets.create_folder "GoogleApps::SheetsManager tested on #{now}"
      @sheet_title = "Sheet from CSV, #{now}"
      @spreadsheet = @sheets.upload_csv_to_spreadsheet(@sheet_title, "Description #{now}", 'fixtures/oec_legacy/courses.csv', @folder.id)
    end

    after(:all) do
      @sheets.trash_item @folder['id'] if @folder
    end

    it 'should upload csv to spreadsheet in target folder' do
      expect(@spreadsheet).to_not be_nil
    end

    it 'should get spreadsheet by id' do
      sheet_by_id = @sheets.spreadsheet_by_id @spreadsheet.id
      expect(sheet_by_id).to_not be nil
      sheet_by_title = @sheets.spreadsheet_by_title @sheet_title
      expect(sheet_by_title).to_not be nil
      # Arbitrary comparison
      expect(sheet_by_id.worksheets[0][2, 2]).to eq sheet_by_title.worksheets[0][2, 2]
    end

  end
end
