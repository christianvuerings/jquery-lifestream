class MyTextbooksController < ApplicationController

  before_filter :api_authenticate

  def get_feed
    render json: Textbooks::Proxy.new({course_catalog: params[:courseCatalog], slug: params[:slug], dept: params[:department], section_numbers: params[:sectionNumbers]}).get_as_json
  end

end
