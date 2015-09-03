describe GoogleApps::SheetsManager do

  context '#real', testext: true, :order => :defined do

    before(:all) do
      settings = Settings.oec.google.marshal_dump
      @sheet_manager = GoogleApps::SheetsManager.new settings[:uid], settings
      now = DateTime.now.strftime('%m/%d/%Y at %I:%M%p')
      @folder = @sheet_manager.create_folder "#{GoogleApps::SheetsManager.name} test, #{now}"
      @sheet_title = "Sheet from CSV, #{now}"
      # No CSV files will be created by this test
      worksheet = Oec::SisImportSheet.new(Rails.root.join('tmp/oec'), dept_code: 'LPSPP')
      course_codes = [Oec::CourseCode.new(dept_name: 'SPANISH', catalog_id: '', dept_code: 'LPSPP', include_in_oec: true)]
      Oec::SisImportTask.new(:term_code => '2015-C').import_courses(worksheet, course_codes)
      @spreadsheet = @sheet_manager.upload_worksheet(@sheet_title, "Description #{now}", worksheet, @folder.id)
    end

    after(:all) do
      @sheet_manager.trash_item @folder['id'] if @folder
    end

    it 'should upload csv to spreadsheet in target folder' do
      expect(@spreadsheet).to_not be_nil
    end

    it 'should get spreadsheet by id' do
      sheet_by_id = @sheet_manager.spreadsheet_by_id @spreadsheet.id
      expect(sheet_by_id).to_not be nil
      spreadsheets = @sheet_manager.spreadsheets_by_title @sheet_title
      expect(spreadsheets).to have(1).item
      sheet_by_title = spreadsheets[0]
      expect(sheet_by_title).to_not be nil
      # Arbitrary comparison
      expect(sheet_by_id.worksheets[0][2, 2]).to eq sheet_by_title.worksheets[0][2, 2]
    end

    it 'should find no spreadsheet mapped to bogus id' do
      sheet_by_id = @sheet_manager.spreadsheet_by_id 'bogus-id'
      expect(sheet_by_id).to be_nil
    end

    it 'should find no spreadsheets with bogus title' do
      spreadsheets = @sheet_manager.spreadsheets_by_title 'let us hope that no spreadsheets have this ridiculous name'
      expect(spreadsheets).to be_empty
    end

  end
end
