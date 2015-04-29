class MediacastsController < ApplicationController

  before_filter :api_authenticate

  def initialize(options = {})
    @options = options
  end

  # GET /api/media/:year/:term_code/:dept/:catalog_id
  def get_media
    term_yr = params['year']
    term_cd = params['term_code']
    dept_name = params['dept']
    catalog_id = params['catalog_id']
    ccn_list = []
    sections = CampusOracle::Queries.get_all_course_sections(term_yr, term_cd, dept_name, catalog_id)
    sections.each { |section| ccn_list << section['course_cntl_num'].to_i } if sections.any?
    render :json => Webcast::CourseMedia.new(term_yr, term_cd, ccn_list, @options).get_feed
  end

end
