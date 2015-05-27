namespace :mailing_lists do

  desc 'Update all mailing list populations'
  task :populate => :environment do
    Rails.logger.warn "Starting update task for #{MailingLists::SiteMailingList.count} mailing lists."
    failed_lists = []
    add = {total: 0, success: 0}
    remove = {total: 0, success: 0}
    MailingLists::SiteMailingList.find_each do |list|
      list.populate
      if list.population_results
        add[:total] += list.population_results[:add][:total]
        add[:success] += list.population_results[:add][:success]
        remove[:total] += list.population_results[:remove][:total]
        remove[:success] += list.population_results[:remove][:success]
      else
        Rails.logger.warn "Update task failed for #{list.list_name}: #{list.request_failure}."
        failed_lists << list.list_name
      end
    end
    Rails.logger.warn "Update complete; #{add[:success]} of #{add[:total]} new members added, #{remove[:success]} of #{remove[:total]} former members removed."
    if failed_lists.any?
      Rails.logger.warn "Update failed on #{failed_lists.count} lists: #{failed_lists.join(', ')}"
    end
  end

end
