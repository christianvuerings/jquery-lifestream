class GoogleDriveListProxy < GoogleDriveProxy

  def drive_list(optional_params={})
    #optional_params.reverse_merge!(:tasklist => '@default', :maxResults => 100)
    request :api => "drive", :resource => "files", :method => "list", :params => optional_params, :vcr_id => "_drive_list"
  end

end
