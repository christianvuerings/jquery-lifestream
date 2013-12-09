namespace :superuser do

  desc "Create a CalCentral superuser"
  task :create => :environment do
    uid = ENV['UID']
    if uid
      UserAuth.new_or_update_superuser! uid
      Rails.logger.warn "Created #{uid} as a superuser"
    else
      Rails.logger.error "No UID passed, nothing to do!"
    end
  end

end
