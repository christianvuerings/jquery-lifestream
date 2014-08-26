class PhotoController < ApplicationController

  before_filter :api_authenticate_401

  def my_photo
    photo_row = User::Photo.fetch(session[:user_id])
    if (photo_row)
      data = photo_row['photo']
      send_data(
        data,
        type: 'image/jpeg',
        disposition: 'inline'
      )
    end
  end

  def has_photo
    render :json => {
      hasPhoto: !!User::Photo.fetch(session[:user_id])
    }
  end

end
