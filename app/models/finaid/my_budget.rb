module Finaid
  class MyBudget < UserSpecificModel
    include ClassLogger

    def append_feed!(feed)
      feed[:finaidBudget] = []
      if Settings.features.cs_fin_aid
        append!(feed)
      end
      feed
    end

    def append!(feed)
      proxy = CampusSolutions::Budget.new({user_id: @uid})
      proxy_feed = proxy.get[:feed]
      return if proxy_feed.blank?
      aid_years = gather_aid_years proxy_feed
      calculate_totals!(aid_years)
      feed[:finaidBudget] = {
        terms: aid_years
      }
    end

    def gather_aid_years(feed)
      aid_years = []
      this_year = {}
      budget_details = feed['UC_STDNT_BUD_DTL_RESP']['UC_STDNT_BUD_DTL']
      budget_details.each do |budget_detail|
        this_year[:items] ||= []
        this_year[:items] << {
          title: budget_detail['BGT_ITEM_CATEGORY_DESCR'],
          amount: budget_detail['BUDGET_ITEM_AMOUNT'].to_i
        }
      end
      aid_years << this_year
      find_terms_for_aid_year(budget_details, this_year)
      logger.debug "aid_years before totals= #{aid_years}"
      aid_years
    end

    def find_terms_for_aid_year(budget_details, this_year)
      first_term = {
        id: 0,
        year: nil,
        term: nil
      }
      last_term = first_term
      details = budget_details.is_a?(Array) ? budget_details : [budget_details.clone]
      details.each do |term_detail|
        next if term_detail['TERM'].blank? || term_detail['TERM_DESCR'].blank?
        this_term = {
          id: term_detail['TERM'].to_i,
          year: term_detail['TERM_DESCR'].split[0],
          term: term_detail['TERM_DESCR'].split[1]
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
      aid_years.each do |this_year|
        this_year[:budgetTotal] ||= 0
        this_year[:items].each do |this_item|
          this_year[:budgetTotal] += this_item[:amount]
        end
      end
      logger.debug "aid_years after totaling #{aid_years}"
    end

  end
end
