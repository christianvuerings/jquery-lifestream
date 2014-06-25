class RostersController < ApplicationController
  include ClassLogger

  def serve_photo
    if (@photo.nil?)
      render :nothing => true, :status => 401
    elsif (data = @photo[:data])
      send_data(
          data,
          type: 'image/jpeg',
          disposition: 'inline'
      )
    else
      send_file(
          @photo[:filename],
          type: 'image/jpeg',
          disposition: 'inline'
      )
    end
  end

end
