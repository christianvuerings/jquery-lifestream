TorqueBox.configure do
  # set a var so that app code can know if TorqueBox features are available.
  environment do
    IS_TORQUEBOX true
  end

  # process incoming JMS messages from activeMQ
  service JmsWorker

  # warm up active users caches once a day
  job HotPlate do
    cron '0 1 8 * * ? *'
    singleton true
  end

  # set up messaging queues
  queue '/queues/hot_plate' do
    durable false
    processor HotPlate do
      if ENV['RAILS_ENV'] == 'production'
        concurrency 3
      end
    end
  end
  queue '/queues/warmup_request' do
    durable false
    processor LiveUpdatesWarmer do
      if ENV['RAILS_ENV'] == 'production'
        concurrency 3
      end
    end
  end
  queue '/queues/feed_changed' do
    durable false
    processor Cache::FeedUpdateWhiteboard
  end

  # Check the health of the background-job processor and the cache.
  service BackgroundJobsCheck
  topic '/topics/background_jobs_check' do
    durable false
    processor BackgroundJobsCheck
  end

end

