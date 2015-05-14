namespace :mailing_lists do

  desc 'Update all mailing list populations'
  task :populate => :environment do
    Rails.logger.warn "Starting update task for #{MailingLists::SiteMailingList.count} mailing lists."
    add = {total: 0, success: 0}
    remove = {total: 0, success: 0}
    MailingLists::SiteMailingList.find_each do |list|
      results = list.populate
      if results[:add] && results[:remove]
        add[:total] += results[:add][:total]
        add[:success] += results[:add][:success]
        remove[:total] += results[:remove][:total]
        remove[:success] += results[:remove][:success]
      elsif results[:error]
        Rails.logger.warn "Update task failed for #{list.list_name}: #{results[:error]}."
      end
    end
    Rails.logger.warn "All mailing lists updated; #{add[:success]} of #{add[:total]} new members added, #{remove[:success]} of #{remove[:total]} former members removed."
  end

end
