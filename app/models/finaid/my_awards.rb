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
      aid_years = gather_aid_years proxy_feed
      calculate_totals!(aid_years)
      feed[:finaidAwards] = {
        terms: aid_years
      }
    end

    def gather_aid_years(feed)
      aid_years = {}
      award_details = feed['SFA_GET_STUDENT_AWARDS_RESP']['STUDENT_AWARD_SUMMARY']['STUDENT_AWARD_DETAIL']
      award_details.each do |award_detail|
        year = award_detail['AID_YEAR']
        type = award_detail['FIN_AID_TYPE_LOVDescr']
        aid_years[year] ||= {}
        this_year = aid_years[year]
        this_year[:categories] ||= {}
        this_year[:categories][type] ||= {
          title: type,
          items: []
        }
        this_item = {
          title: award_detail['ITEM_TYPE_LOVDescr'],
          amount: award_detail['OFFER_BALANCE'],
          amountAccepted: award_detail['ACCEPT_BALANCE'],
          type: award_detail['FIN_AID_TYPE_LOVDescr'],
          status: award_detail['SFA_AWARD_STATUS_LOVDescr']
        }
        this_year[:categories][type][:items] << this_item
        find_terms_for_aid_year(award_detail, this_year)
      end
      logger.debug "aid_years before totals= #{aid_years}"
      aid_years
    end

    def find_terms_for_aid_year(award_detail, this_year)
      first_term = {
        id: 0,
        year: nil,
        term: nil
      }
      last_term = first_term
      award_detail['STUDENT_TERM_DETAIL'].each do |term_detail|
        this_term = {
          id: term_detail['STRM'].to_i,
          year: term_detail['STRM_LOVDescr'].split[0],
          term: term_detail['STRM_LOVDescr'].split[1]
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

    def calculate_totals!(aid_years)
      aid_years.keys.each do |year|
        this_year = aid_years[year]
        this_year[:totalOffered] ||= 0
        this_year[:totalAccepted] ||= 0
        this_year[:categories].keys.each do |category|
          this_category = this_year[:categories][category]
          this_category[:total] ||= 0
          this_category[:items].each do |item|
            this_category[:total] += item[:amount].to_i
            this_year[:totalOffered] += item[:amount].to_i
            this_year[:totalAccepted] += item[:amountAccepted].to_i
          end
        end
      end
      logger.debug "aid_years after totaling #{aid_years}"
    end

  end
end
