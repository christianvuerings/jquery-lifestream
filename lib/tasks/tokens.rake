namespace :tokens do
  desc "Migrate tokens into a temporary (eventually discarded) holding space"
  task :move => :environment do
    destination = DateTime.now.strftime('%Y%m%d%H%M%S%2N')
    %w(Google Canvas).each do |app_key|
      new_app_key = app_key + "-#{destination}"
      p "Moving #{app_key} tokens to #{new_app_key}"
      Oauth2Data.where(:app_id => "#{app_key}").each do |entry|
        entry.update_attribute :app_id, "#{new_app_key}"
      end
    end
  end
end
