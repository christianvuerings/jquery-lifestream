namespace :webcast do

  desc 'Manage Webcast tool placement across all Canvas course sites'
  task :canvas_integration => :environment do
    course_id = ENV['course_id'].to_s.to_i
    if course_id > 0
      Rails.logger.warn "Updating Webcast LTI configuration on Canvas course site #{course_id}"
      options = ENV.merge(course_id: course_id)
      Webcast::RefreshLTI.new(options).refresh_canvas
      Rails.logger.warn "Webcast LTI refreshed on Canvas course site #{course_id}"
    else
      Rails.logger.warn 'usage: rake webcast:canvas_integration course_id=[course_id]'
    end
  end

end
