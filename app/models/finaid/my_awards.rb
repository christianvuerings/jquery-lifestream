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
        aid_year = award_detail['AID_YEAR']
        type = award_detail['FIN_AID_TYPE_LOVDescr']
        aid_years[aid_year] ||= {}
        aid_years[aid_year][:categories] ||= {}
        aid_years[aid_year][:categories][type] ||= {
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
        aid_years[aid_year][:categories][type][:items] << this_item
        award_detail['STUDENT_TERM_DETAIL'].each do |term_detail|
          term_name = term_detail['STRM_LOVDescr']
          term_id = term_detail['STRM']
          logger.debug "Processing term detail #{term_id}-#{term_name}"
        end
      end
      logger.debug "aid_years before totals= #{aid_years}"
      aid_years
    end

    def calculate_totals!(aid_years)
      # TODO during this loop figure out startTerm and endTerm. can CS STRM values be sorted and compared?
      aid_years.keys.each do |year|
        aid_years[year][:totalOffered] ||= 0
        aid_years[year][:totalAccepted] ||= 0
        aid_years[year][:categories].keys.each do |category|
          aid_years[year][:categories][category][:total] ||= 0
          aid_years[year][:categories][category][:items].each do |item|
            aid_years[year][:categories][category][:total] += item[:amount].to_i
            aid_years[year][:totalOffered] += item[:amount].to_i
            aid_years[year][:totalAccepted] += item[:amountAccepted].to_i
          end
        end
      end
      logger.debug "aid_years after totaling #{aid_years}"
    end

  end
end
