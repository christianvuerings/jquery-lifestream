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
    sections = CampusOracle::Queries.get_all_course_sections(term_yr, term_cd, dept_name, catalog_id)
    ccn_list = sections.map { |section| section['course_cntl_num'].to_i }
    policy = policy(Berkeley::Course.new @options)
    uid = session['user_id']
    render :json => Webcast::Merged.new(uid, policy, term_yr, term_cd, ccn_list, @options).get_feed
  end

end
