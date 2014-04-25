class PhotoController < ApplicationController

  before_action :asset_authenticate

  def asset_authenticate
    render :nothing => true, :status => 401 if session[:user_id].blank?    
  end

  def my_photo
    photo_row = User::Photo.fetch(session[:user_id])
    if (photo_row)
      data = photo_row['photo']
      send_data(
        data,
        type: 'image/jpeg',
        disposition: 'inline'
      )
    else 
      send_file(
        File.join(Rails.root, 'app/assets/images', 'photo_unavailable_official_72x96.jpg'),
        type: 'image/jpeg',
        disposition: 'inline'
      )
    end
  end

end
