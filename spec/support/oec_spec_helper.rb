module OecSpecHelper

  def expect_file_upload(file_name, parent_name, type)
    expect(fake_sheets_manager).to receive(:find_items_by_title)
     .with(file_name, parent_id: mock_file(parent_name).id)
     .and_return []
    expect(fake_sheets_manager).to receive(:upload_file)
     .with(file_name, '', mock_file(parent_name).id, type, Rails.root.join('tmp', 'oec', file_name).to_s)
     .and_return(mock_file(file_name))
  end

  def expect_folder_creation(folder_name, parent_name, opts={})
    expect(fake_sheets_manager).to receive(:create_folder)
      .with(folder_name, mock_file(parent_name).id)
      .and_return mock_file(folder_name)
    if opts[:read_after_creation]
      expect(fake_sheets_manager).to receive(:find_folders_by_title)
        .at_least(2).times
        .with(folder_name, mock_file(parent_name).id)
        .and_return([], [mock_file(folder_name)])
    else
      expect(fake_sheets_manager).to receive(:find_folders_by_title)
        .at_least(1).times
        .with(folder_name, mock_file(parent_name).id)
        .and_return([])
    end
  end

  def expect_folder_lookup(folder_name, parent_name)
    expect(fake_sheets_manager).to receive(:find_folders_by_title)
     .with(folder_name, mock_file(parent_name).id)
     .at_least(1).times
     .and_return([mock_file(folder_name)])
  end

  def expect_sheet_upload(file_name, parent_name)
    expect(fake_sheets_manager).to receive(:find_items_by_title)
      .with(file_name.chomp('.csv'), parent_id: mock_file(parent_name).id)
      .and_return []
    expect(fake_sheets_manager).to receive(:upload_csv_to_spreadsheet)
      .with(file_name.chomp('.csv'), '', Rails.root.join('tmp', 'oec', file_name).to_s, mock_file(parent_name).id)
      .and_return(mock_file(file_name))
  end

  def mock_file(file_name)
    if file_name == 'root'
      double(title: nil, id: 'root')
    else
      double(title: file_name, id: "#{file_name}_id")
    end
  end

end
