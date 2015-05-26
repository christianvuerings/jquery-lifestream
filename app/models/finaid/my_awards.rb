module Finaid
  class MyAwards < UserSpecificModel
    include ClassLogger

    def append_feed!(feed)
      feed[:finaidAwards] = []
      if Settings.features.cs_fin_aid
        append!(feed)
      end
      feed
    end

    def append!(feed)
      proxy = CampusSolutions::Awards.new({user_id: @uid})
      proxy_feed = proxy.get[:feed]
      return if proxy_feed.blank?
      aid_years = gather_aid_years proxy_feed
      convert_categories_to_array!(aid_years)
      calculate_totals!(aid_years)
      feed[:finaidAwards] = {
        terms: aid_years
      }
    end

    def gather_aid_years(feed)
      aid_years = {}
      award_details = feed[:sfaGetStudentAwardsResp][:studentAwardSummary][:studentAwardDetail]
      award_details.each do |award_detail|
        year = award_detail[:aidYear]
        type = award_detail[:finAidTypeLovdescr]
        aid_years[year] ||= {}
        this_year = aid_years[year]
        this_year[:categories] ||= {}
        this_year[:categories][type] ||= {
          title: type,
          items: []
        }
        this_item = {
          title: award_detail[:itemTypeLovdescr],
          amount: award_detail[:offerBalance].to_i,
          amountAccepted: award_detail[:acceptBalance].to_i,
          type: award_detail[:finAidTypeLovdescr],
          status: award_detail[:sfaAwardStatusLovdescr]
        }
        this_year[:categories][type][:items] << this_item
        find_terms_for_aid_year(award_detail, this_year)
      end
      aid_years = aid_years.values
      logger.debug "aid_years before totals= #{aid_years}"
      aid_years
    end

    def find_terms_for_aid_year(award_detail, this_year)
      return if award_detail[:studentTermDetail].blank?
      first_term = {
        id: 0,
        year: nil,
        term: nil
      }
      last_term = first_term
      details = award_detail[:studentTermDetail].is_a?(Array) ? award_detail[:studentTermDetail] : [award_detail[:studentTermDetail].clone]
      details.each do |term_detail|
        next if term_detail[:strm].blank? || term_detail[:strmLovdescr].blank?
        this_term = {
          id: term_detail[:strm].to_i,
          year: term_detail[:strmLovdescr].split[0],
          term: term_detail[:strmLovdescr].split[1]
        }
        logger.debug "Processing term detail #{this_term.inspect}"
        if last_term[:id] == 0 || this_term[:id] > last_term[:id]
          last_term = this_term
        end
        if first_term[:id] == 0 || this_term[:id] < first_term[:id]
          first_term = this_term
        end
      end
      this_year[:startTerm] = first_term[:term]
      this_year[:startTermYear] = first_term[:year]
      this_year[:endTerm] = last_term[:term]
      this_year[:endTermYear] = last_term[:year]
    end

    def convert_categories_to_array!(aid_years)
      aid_years.each do |year|
        category_array = year[:categories].values
        year[:categories] = category_array
      end
      aid_years
    end

    def calculate_totals!(aid_years)
      aid_years.each do |this_year|
        this_year[:totalOffered] ||= 0
        this_year[:totalAccepted] ||= 0
        this_year[:categories].each do |this_category|
          this_category[:total] ||= 0
          this_category[:items].each do |item|
            this_category[:total] += item[:amount]
            this_year[:totalOffered] += item[:amount]
            this_year[:totalAccepted] += item[:amountAccepted]
          end
        end
      end
      logger.debug "aid_years after totaling #{aid_years}"
    end

  end
end
